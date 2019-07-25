//
//  CZHTTPCache.swift
//  CZNetworking
//
//  Created by Cheng Zhang on 1/13/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import CZUtils

/// Local Cache class for HTTP response
open class CZHTTPCache: NSObject {
    private let ioQueue: DispatchQueue
    
    override init() {
        ioQueue = DispatchQueue(
            label: "com.tony.httpCache.ioQueue",
            qos: .default,
            attributes: .concurrent,
            autoreleaseFrequency: .inherit,
            target: nil)
        super.init()
    }

    private let folder: URL = {
        var documentPath = try! FileManager.default.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let cacheFolder = documentPath.appendingPathComponent("CZHTTPCache")
        do {
            try FileManager.default.createDirectory(atPath: cacheFolder.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            assertionFailure("Failed to create HTTPCache folder. Error: \(error)")
        }
        return cacheFolder
    }()
    static func cacheKey(url: URL, params: [AnyHashable: Any]?) -> String {
        return CZHTTPJsonSerializer.url(baseURL: url, params: params).absoluteString
    }

    func saveData(_ data: Any, forKey key: String) {
        ioQueue.async(flags: .barrier) {[weak self] in
            guard let `self` = self else {return}
            switch data {
            case let data as NSDictionary:
                data.write(to: self.fileURL(forKey: key), atomically: false)
            case let data as NSArray:
                data.write(to: self.fileURL(forKey: key), atomically: false)
            case let data as Data:
                do {
                    try data.write(to: self.fileURL(forKey: key), options: .atomic)
                } catch {
                    dbgPrint("Failed to write data. Error - \(error.localizedDescription)")
                }
            default:
                assertionFailure("Unsupported data type.")
                return
            }
        }
    }
    
    func readData(forKey key: String) -> Any? {
        return ioQueue.sync {[weak self] () -> Any? in
            guard let `self` = self else { return nil }
            if let dict = NSDictionary(contentsOf: self.fileURL(forKey: key)) {
                return dict
            }
            if let array = NSArray(contentsOf: self.fileURL(forKey: key)) {
                return array
            }
            if let dict = NSDictionary(contentsOf: self.fileURL(forKey: key)) {
                return dict
            }
            do {
                let data = try Data(contentsOf: self.fileURL(forKey: key))
                return data
            } catch {
                dbgPrint("Failed to read data. Error - \(error.localizedDescription)")
            }
            return nil
        }
    }
}

private extension CZHTTPCache {
    func fileURL(forKey key: String) -> URL {
        return folder.appendingPathComponent(key.MD5)
    }
}

protocol FileWritable {
    func write(toFile: String, atomically: Bool) -> Bool
}



