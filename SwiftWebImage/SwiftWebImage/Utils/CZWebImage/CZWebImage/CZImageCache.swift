//
//  CZImageCache.swift
//  CZWebImage
//
//  Created by Cheng Zhang on 1/22/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils
import CZNetworking

/**
 Thread safe local cache backed by DispatchQueue mutex lock/LRU queue, supports maxFileAge/maxCacheSize purging strategy
 */
class CZImageCache: NSObject {
    
    public static let shared = CZImageCache()
    
    typealias CachedItemsInfo = [String: [String: Any]]
    public typealias CleanDiskCacheCompletion = () -> Void
    private enum Constant {
        static let kCachedItemsInfoFile = "cachedItemsInfo.plist"
        static let kFileModifiedDate = "modifiedDate"
        static let kFileVisitedDate = "visitedDate"
        static let kFileSize = "size"
        static let kMaxFileAge: TimeInterval = 60 * 24 * 60 * 60
        static let kMaxCacheSize: Int = 500 * 1024 * 1024
        static let ioQueueLabel = "com.tony.cache.ioQueue"
    }
    
    private var ioQueue: DispatchQueue
    private var memCache: NSCache<NSString, UIImage>
    private var fileManager: FileManager
    private var operationQueue: OperationQueue
    private var hasCachedItemsInfoToFlushToDisk: Bool = false
    
    private lazy var cachedItemsInfoFileURL: URL = {
        return URL(fileURLWithPath: CZCacheFileManager.cacheFolder + "/" + Constant.kCachedItemsInfoFile)
    }()
    private lazy var cachedItemsInfoLock: CZMutexLock<CachedItemsInfo> = {
        let cachedItemsInfo: CachedItemsInfo = loadCachedItemsInfo() ?? [:]
        return CZMutexLock(cachedItemsInfo)
    }()
    private(set) var maxCacheAge: TimeInterval
    private(set) var maxCacheSize: Int
    
    public init(maxCacheAge: TimeInterval = Constant.kMaxFileAge,
                maxCacheSize: Int = Constant.kMaxCacheSize) {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 60
        
        ioQueue = DispatchQueue(label: Constant.ioQueueLabel,
                                qos: .userInitiated,
                                attributes: .concurrent)
        
        fileManager = FileManager()
        
        // Memory cache
        memCache = NSCache()
        memCache.countLimit = 1000
        memCache.totalCostLimit = 1000 * 1024 * 1024
        
        self.maxCacheAge = maxCacheAge
        self.maxCacheSize = maxCacheSize
        super.init()
        
        // Clean cache
        cleanDiskCacheIfNeeded()
    }
    
    public func setCacheFile(withUrl url: URL, data: Data?) {
        guard let data = data else {return}
        let (fileURL, cacheKey) = getCacheFileInfo(forURL: url)
        // Mem cache
        if let image = UIImage(data: data) {
            setMemCache(image: image, forKey: cacheKey)
        }
        
        // Disk cache
        ioQueue.async(flags: .barrier) { [weak self] in
            guard let `self` = self else {return}
            do {
                try data.write(to: fileURL)
                self.setCachedItemsInfo(key: cacheKey, subkey: Constant.kFileModifiedDate, value: NSDate())
                self.setCachedItemsInfo(key: cacheKey, subkey: Constant.kFileVisitedDate, value: NSDate())
                self.setCachedItemsInfo(key: cacheKey, subkey: Constant.kFileSize, value: data.count)
            } catch {
                assertionFailure("Failed to write file. Error - \(error.localizedDescription)")
            }
        }
    }    
    
    public func getCachedFile(with url: URL, completion: @escaping (UIImage?) -> Void)  {        
        let (fileURL, cacheKey) = self.getCacheFileInfo(forURL: url)
        // Read data from mem cache
        var image: UIImage? = self.getMemCache(forKey: cacheKey)
        // Read data from disk cache
        if image == nil {
            image = self.ioQueue.sync {
                if let data = try? Data(contentsOf: fileURL),
                    let image = UIImage(data: data) {
                    // Update last visited date
                    self.setCachedItemsInfo(key: cacheKey, subkey: Constant.kFileVisitedDate, value: NSDate())
                    // Set mem cache after loading data from local drive
                    self.setMemCache(image: image, forKey: cacheKey)
                    return image
                }
                return nil
            }
        }
        // Completion callback
        CZMainQueueScheduler.sync {
            completion(image)
        }
    }
    
    func cleanDiskCacheIfNeeded(completion: CleanDiskCacheCompletion? = nil){
        let currDate = Date()
        
        // 1. Clean disk by age
        let removeFileURLs = cachedItemsInfoLock.writeLock { (cachedItemsInfo: inout CachedItemsInfo) -> [URL] in
            var removedKeys = [String]()
            
            // Remove key if its fileModifiedDate exceeds maxCacheAge
            cachedItemsInfo.forEach { (keyValue: (key: String, value: [String : Any])) in
                if let modifiedDate = keyValue.value[Constant.kFileModifiedDate] as? Date,
                    currDate.timeIntervalSince(modifiedDate) > self.maxCacheAge {
                    removedKeys.append(keyValue.key)
                    cachedItemsInfo.removeValue(forKey: keyValue.key)
                }
            }
            self.flushCachedItemsInfoToDisk(cachedItemsInfo)
            let removeFileURLs = removedKeys.compactMap{ self.cacheFileURL(forKey: $0) }
            return removeFileURLs
        }
        // Remove corresponding files from disk
        self.ioQueue.async(flags: .barrier) { [weak self] in
            guard let `self` = self else {return}
            removeFileURLs?.forEach {
                do {
                    try self.fileManager.removeItem(at: $0)
                } catch {
                    assertionFailure("Failed to remove file. Error - \(error.localizedDescription)")
                }
            }
        }
        
        // 2. Clean disk by maxSize setting: based on visited date - simple LRU
        if self.size > self.maxCacheSize {
            let expectedCacheSize = self.maxCacheSize / 2
            let expectedReduceSize = self.size - expectedCacheSize

            let removeFileURLs = cachedItemsInfoLock.writeLock { (cachedItemsInfo: inout CachedItemsInfo) -> [URL] in
                // Sort files with last visted date
                let sortedItemsInfo = cachedItemsInfo.sorted { (keyValue1: (key: String, value: [String : Any]),
                    keyValue2: (key: String, value: [String : Any])) -> Bool in
                    if let modifiedDate1 = keyValue1.value[Constant.kFileVisitedDate] as? Date,
                        let modifiedDate2 = keyValue2.value[Constant.kFileVisitedDate] as? Date {
                        return modifiedDate1.timeIntervalSince(modifiedDate2) < 0
                    } else {
                        fatalError()
                    }
                }
                
                var removedFilesSize: Int = 0
                var removedKeys = [String]()
                for (key, value) in sortedItemsInfo {
                    if removedFilesSize >= expectedReduceSize {
                        break
                    }
                    cachedItemsInfo.removeValue(forKey: key)
                    removedKeys.append(key)
                    let oneFileSize = (value[Constant.kFileSize] as? Int) ?? 0
                    removedFilesSize += oneFileSize
                }
                self.flushCachedItemsInfoToDisk(cachedItemsInfo)
                return removedKeys.compactMap {self.cacheFileURL(forKey: $0)}
            }
            
            // Remove corresponding files from disk
            self.ioQueue.async(flags: .barrier) { [weak self] in
                guard let `self` = self else {return}
                removeFileURLs?.forEach {
                    do {
                        try self.fileManager.removeItem(at: $0)
                    } catch {
                        assertionFailure("Failed to remove file. Error - \(error.localizedDescription)")
                    }
                }
            }
        }
        
        completion?()
    }
    
    var size: Int {
        return cachedItemsInfoLock.readLock { [weak self] (cachedItemsInfo: CachedItemsInfo) -> Int in
            guard let `self` = self else {return 0}
            return self.getSizeWithoutLock(cachedItemsInfo: cachedItemsInfo)
        } ?? 0
    }
}

// MARK: - Private methods

private extension CZImageCache {
    func getSizeWithoutLock(cachedItemsInfo: CachedItemsInfo) -> Int {
        var totalCacheSize: Int = 0
        for (_, value) in cachedItemsInfo {
            let oneFileSize = (value[Constant.kFileSize] as? Int)  ?? 0
            totalCacheSize += oneFileSize
        }
        return totalCacheSize
    }
    
    func loadCachedItemsInfo() -> CachedItemsInfo? {
        return NSDictionary(contentsOf: cachedItemsInfoFileURL) as? CachedItemsInfo
    }
    
    func setCachedItemsInfo(key: String, subkey: String, value: Any) {
        cachedItemsInfoLock.writeLock { [weak self] (cachedItemsInfo) -> Void in
            guard let `self` = self else {return}
            if cachedItemsInfo[key] == nil {
                cachedItemsInfo[key] = [:]
            }
            cachedItemsInfo[key]?[subkey] = value
            self.flushCachedItemsInfoToDisk(cachedItemsInfo)
        }
    }
    
    func removeCachedItemsInfo(forKey key: String) {
        cachedItemsInfoLock.writeLock { [weak self] (cachedItemsInfo) -> Void in
            guard let `self` = self else {return}
            cachedItemsInfo.removeValue(forKey: key)
            self.flushCachedItemsInfoToDisk(cachedItemsInfo)
        }
    }
    
    func flushCachedItemsInfoToDisk(_ cachedItemsInfo: CachedItemsInfo) {
        (cachedItemsInfo as NSDictionary).write(to: cachedItemsInfoFileURL, atomically: true)
    }
    
    func getMemCache(forKey key: String) -> UIImage? {
        return memCache.object(forKey: NSString(string: key))
    }
    
    func setMemCache(image: UIImage, forKey key: String) {
        memCache.setObject(image,
                           forKey: NSString(string: key),
                           cost: cacheCost(forImage: image))
    }

    func cacheCost(forImage image: UIImage) -> Int {
        return Int(image.size.height * image.size.width * image.scale * image.scale)
    }
    
    
    typealias CacheFileInfo = (fileURL: URL, cacheKey: String)
    func getCacheFileInfo(forURL url: URL) -> CacheFileInfo {
        let cacheKey = url.absoluteString.MD5
        let fileURL = URL(fileURLWithPath: CZCacheFileManager.cacheFolder + url.absoluteString.MD5)
        return (fileURL: fileURL, cacheKey: cacheKey)
    }
    
    func cacheFileURL(forKey key: String) -> URL {
        return URL(fileURLWithPath: CZCacheFileManager.cacheFolder + key)
    }
}
