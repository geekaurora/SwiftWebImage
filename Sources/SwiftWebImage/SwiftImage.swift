//
//  SwiftImage.swift
//
//  Created by Cheng Zhang on 7/20/19.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import SwiftUI
import CZWebImage

/// SwiftUI image downloader with performant LRU mem/disk cache.
///
/// ### Usage

public struct SwiftImage<V: View>: View {
  
  @ObservedObject private var imageDownloader = SwiftImageDownloader()
  
  public typealias Config<V> = (Image) -> V where V: View
  
  private let placeholder: UIImage
  private let config: Config<V>?
  
  /// Initializer of SwiftImage view with specified params.
  ///
  /// - Parameters:
  ///   - url: The url to download the image.
  ///   - placeholder: The placeholder image.
  ///   - config: Closure be used to config SwiftImage view.
  public init(url: String?,
              placeholder: UIImage = UIImage(),
              config: Config<V>? = nil) {
    self.placeholder = placeholder
    self.config = config
    imageDownloader.download(url: url)
  }
  
  public var body: some View {
    let image: UIImage = imageDownloader.image ?? placeholder
    let imageView = Image(uiImage: image)
    if let config = config {
      return AnyView(config(imageView))
    }
    return AnyView(imageView)
  }
  
}
