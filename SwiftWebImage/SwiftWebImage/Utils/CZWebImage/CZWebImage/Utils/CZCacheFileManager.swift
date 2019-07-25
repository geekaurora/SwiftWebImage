//
//  CZCacheFileManager.swift
//  CZWebImage
//
//  Created by Cheng Zhang on 1/18/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils

/// CacheFileManager helper class
internal class CZCacheFileManager: NSObject {
    static let cacheFolder: String = {
        let cacheFolder = CZFileHelper.documentDirectory + "CZCache/"
        
        let fileManager = FileManager()
        if !fileManager.fileExists(atPath: cacheFolder) {
            do {
                try fileManager.createDirectory(atPath: cacheFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                assertionFailure("Failed to create CacheFolder! Error - \(error.localizedDescription); Folder - \(cacheFolder)")
            }
        }
        return cacheFolder
    }()
}
