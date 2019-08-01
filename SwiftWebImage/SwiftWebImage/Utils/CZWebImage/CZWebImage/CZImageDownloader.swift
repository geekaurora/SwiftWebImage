//
//  CZImageDownloader.swift
//  CZWebImage
//
//  Created by Cheng Zhang on 1/20/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils
import CZNetworking

private var kvoContext: UInt8 = 0

public typealias CZImageDownloderCompletion = (_ image: UIImage?, _ error: Error?, _ fromCache: Bool) -> Void

/**
 Asynchronous image downloading class on top of OperationQueue
 */
public class CZImageDownloader: NSObject {
    public static let shared = CZImageDownloader()
    private let imageDownloadQueue: OperationQueue
    private let imageDecodeQueue: OperationQueue
    private enum Constant {
        static let imageDownloadQueueName = "com.tony.image.download"
        static let imageDecodeQueueName = "com.tony.image.decode"
    }
    
    public override init() {
        imageDownloadQueue = OperationQueue()
        imageDownloadQueue.name = Constant.imageDownloadQueueName
        imageDownloadQueue.qualityOfService = .userInteractive
        imageDownloadQueue.maxConcurrentOperationCount = CZWebImageConstants.downloadQueueMaxConcurrent
        
        imageDecodeQueue = OperationQueue()
        imageDownloadQueue.name = Constant.imageDecodeQueueName
        imageDecodeQueue.maxConcurrentOperationCount = CZWebImageConstants.decodeQueueMaxConcurrent
        super.init()
        
        if CZWebImageConstants.shouldObserveOperations {
            imageDownloadQueue.addObserver(self, forKeyPath: CZWebImageConstants.kOperations, options: [.new, .old], context: &kvoContext)
        }
    }
    
    deinit {
        if CZWebImageConstants.shouldObserveOperations {
            imageDownloadQueue.removeObserver(self, forKeyPath: CZWebImageConstants.kOperations)
        }
        imageDownloadQueue.cancelAllOperations()
    }
    
    public func downloadImage(with url: URL?,
                       cropSize: CGSize? = nil,
                       priority: Operation.QueuePriority = .normal,
                       completionHandler: @escaping CZImageDownloderCompletion) {
        guard let url = url else {return}
        cancelDownload(with: url)
        
        let queue = imageDownloadQueue
        let operation = ImageDownloadOperation(url: url,
                                               progress: nil,
                                               success: { [weak self] (task, data) in
            guard let `self` = self, let data = data else {preconditionFailure()}
            // Decode/crop image in decode OperationQueue
            self.imageDecodeQueue.addOperation {
                var internalData: Data? = data
                var image = UIImage(data: data)
                if let cropSize = cropSize, cropSize != .zero {
                    image = image?.crop(toSize: cropSize)
                    internalData =  (image == nil) ? nil : image!.pngData()
                }
                CZImageCache.shared.setCacheFile(withUrl: url, data: internalData)
                
                // Call completionHandler on mainQueue
                CZMainQueueScheduler.async {
                    completionHandler(image, nil, false)
                }
            }
        }, failure: { (task, error) in
            CZUtils.dbgPrint("DOWNLOAD ERROR: \(error.localizedDescription)")
            completionHandler(nil, error, false)
        })
        operation.queuePriority = priority
        queue.addOperation(operation)
    }
    
    @objc(cancelDownloadWithURL:)
    public func cancelDownload(with url: URL?) {
        guard let url = url else {return}
        
        let cancelIfNeeded = { (operation: Operation) in
            if let operation = operation as? ImageDownloadOperation,
                operation.url == url {
                operation.cancel()
            }
        }
        imageDownloadQueue.operations.forEach(cancelIfNeeded)
    }
}

// MARK: - KVO Delegation

extension CZImageDownloader {
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &kvoContext,
            let object = object as? OperationQueue,
            let keyPath = keyPath,
            keyPath == CZWebImageConstants.kOperations else {
                return
        }
        if object === imageDownloadQueue {
            CZUtils.dbgPrint("Queued tasks: \(object.operationCount)")
        }
    }
}
