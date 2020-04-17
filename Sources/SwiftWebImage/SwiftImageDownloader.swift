//
//  SwiftImageDownloader.swift
//
//  Created by Cheng Zhang on 7/20/19.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import SwiftUI
import CZWebImage

public class SwiftImageDownloader: ObservableObject {
  
  @Published var image: UIImage?
  
  private var url: URL?
  
  /// Fetches image data with `url` and triggers ui reload on completion.
  public func download(url: URL) {
    self.url = url
    
    CZWebImageManager.shared.downloadImage(with: url) { (image, error, fromCache) in
      // Verify download imageUrl matches the original one.
      guard self.url == url else { return }
      self.image = image
    }
  }
}
