//
//  CZWebImageManager.swift
//  CZWebImage
//
//  Created by Cheng Zhang on 1/20/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils
import CZNetworking

/**
 Web image manager maintains asynchronous image downloading tasks
 */
@objc open class CZWebImageManager: NSObject {

    public static let shared: CZWebImageManager = CZWebImageManager()
    private var downloader: CZImageDownloader
    private var cache: CZImageCache
    
    public override init() {
        downloader = CZImageDownloader()
        cache = CZImageCache()
        super.init()
    }
    
    public func downloadImage(with url: URL,
                       cropSize: CGSize? = nil,
                       priority: Operation.QueuePriority = .normal,
                       completionHandler: @escaping CZImageDownloderCompletion) {
        cache.getCachedFile(with: url) { [weak self] (image) in
            guard let `self` = self else {return}
            if let image = image {
                // Load from local disk
                CZMainQueueScheduler.sync {
                    completionHandler(image, nil, true)
                }
                return
            }
            // Load from http service
            self.downloader.downloadImage(with: url,
                                          cropSize: cropSize,
                                          priority: priority,
                                          completionHandler: completionHandler)
        }
    }
    
    @objc(cancelDownloadWithURL:)
    public func cancelDownload(with url: URL) {
        downloader.cancelDownload(with: url)
    }
}
