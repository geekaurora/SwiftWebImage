//
//  CZWebImageError.swift
//  CZWebImage
//
//  Created by Cheng Zhang on 1/19/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils
import CZNetworking

/// Error class for CZWebImage
open class CZWebImageError: CZError {
    public init(_ description: String? = nil, code: Int = 99) {
        super.init(domain: CZWebImageConstants.errorDomain, code: code, description: description)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
