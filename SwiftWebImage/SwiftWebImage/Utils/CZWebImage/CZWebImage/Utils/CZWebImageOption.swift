//
//  CZWebImageOption.swift
//  CZWebImage
//
//  Created by Cheng Zhang on 1/18/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit

/// CZWebImageOption for Swift
public struct CZWebImageOption: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public static let fadeInAnimation  = CZWebImageOption(rawValue: CZWebImageOptionOC.fadeInAnimation.rawValue)
    public static let highPriority  = CZWebImageOption(rawValue: CZWebImageOptionOC.highPriority.rawValue)
}

/// Bridging CZWebImageOption for OC
@objc public enum CZWebImageOptionOC: Int {
    case fadeInAnimation = 1    // 1 << 0
    case highPriority = 2       // 1 << 1
}
