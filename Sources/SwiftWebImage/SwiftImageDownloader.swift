//
//  SwiftImageDownloader.swift
//
//  Created by Cheng Zhang on 7/20/19.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import SwiftUI
import CZWebImage

class SwiftImageDownloader: ObservableObject {
  
  @Published var image: UIImage?
  
  private var url: String?
  
  func download(url: String?) {
    // Fetches image data and triggers reload by setting `image` on completion.
    self.url = url
    guard let url = url,
      let imageUrl = URL(string: url) else {
        return
    }
    CZWebImageManager.shared.downloadImage(with: imageUrl) { (image, error, fromCache) in
      // Verify download imageUrl matches the original one.
      guard self.url == url else {
        return
      }
      self.image = image
    }
  }
}
