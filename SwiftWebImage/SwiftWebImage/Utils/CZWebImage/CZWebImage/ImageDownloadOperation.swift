//
//  CZImageDownloadOperation.swift
//  CZWebImage
//
//  Created by Cheng Zhang on 1/22/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import Foundation
import CZUtils
import CZNetworking

/**
 Concurrent operation class for image downloading OperationQueue, supports success/failure/progress callback
 */
class ImageDownloadOperation: CZConcurrentOperation {
    
    private var requester: HTTPRequestWorker?
    private var progress: HTTPRequestWorker.Progress?
    private var success: HTTPRequestWorker.Success?
    private var failure: HTTPRequestWorker.Failure?
    let url: URL

    required init(url: URL,
                  progress: HTTPRequestWorker.Progress? = nil,
                  success: HTTPRequestWorker.Success?,
                  failure: HTTPRequestWorker.Failure?) {
        self.url = url
        self.progress = progress
        super.init()
        
        self.success = { [weak self] (data, reponse) in
            // Update Operation's `isFinished` prop
            self?.finish()
            success?(data, reponse)
        }
        
        self.failure = { [weak self] (reponse, error) in
            // Update Operation's `isFinished` prop
            self?.finish()
            failure?(reponse, error)
        }
    }
    
    override func execute() {
        downloadImage(url: url)
    }
    
    override func cancel() {
        super.cancel()
        requester?.cancel()
        finish()
    }
    
}

private extension ImageDownloadOperation {
    func downloadImage(url: URL) {
        requester = HTTPRequestWorker(
            .GET,
            url: url,
            params: nil,
            shouldSerializeJson: false,
            success: success,
            failure: failure,
            progress: progress)
        requester?.start()
    }
}




