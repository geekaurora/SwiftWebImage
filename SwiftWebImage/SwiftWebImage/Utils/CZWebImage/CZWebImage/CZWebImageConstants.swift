//
//  CZWebImageConstants.swift
//  CZWebImage
//
//  Created by Cheng Zhang on 1/18/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit

/**
 Constants of CZWebImage
 */
enum CZWebImageConstants {
    static let shouldObserveOperations: Bool = false
    static let downloadQueueMaxConcurrent: Int = 50
    static let decodeQueueMaxConcurrent: Int = downloadQueueMaxConcurrent
    static let kOperations = "operations"
    static let errorDomain = "CZWebImage"
    static let kFadeAnimation = "com.tony.webimage.fadeAnimation"
}
