//
//  SwiftImage.swift
//
//  Created by Cheng Zhang on 7/20/19.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import SwiftUI
import SwiftUIKit
import CZWebImage

/// SwiftUI image downloader with performant LRU mem/disk cache.
///
/// ### Usage Samples
///
///  - `import SwiftWebImage` and set `url` for `SwiftImage`:
///  ```
///  SwiftImage<Image>(imageUrl)
///  ```
///  Framework will automatically load Image with `@ObservedObject` data once download completes.
///
///  - To config Image, trailing `config` block of `SwiftImage` is used for underlying ImageView configuration:
///  ```
///  SwiftImage(imageUrl) { imageView in
///    imageView
///      .resizable()
///      .aspectRatio(1, contentMode: .fit)
///  }
///  ```
public struct SwiftImage<V: View>: View {
  
  @ObservedObject private var imageDownloader = SwiftImageDownloader()
  
  public typealias Config<V> = (Image) -> V
  
  private let placeholder: UIImage
  private let config: Config<V>?
  
  /// Initializer of SwiftImage view with specified params.
  ///
  /// - Parameters:
  ///   - url: The string to download the image.
  ///   - placeholder: The placeholder image.
  ///   - config: Closure be used to config SwiftImage view.
  public init(_ url: URL?,
              placeholder: UIImage = UIImage(),
              config: Config<V>? = nil) {
    self.placeholder = placeholder
    self.config = config
    if let url = url {
      imageDownloader.download(url: url)
    }
  }
  
  /// Convenience initializer of SwiftImage view with specified params.
  ///
  /// - Parameters:
  ///   - urlString: The url string to download the image.
  ///   - placeholder: The placeholder image.
  ///   - config: Closure be used to config SwiftImage view.
  public init(_ urlString: String?,
              placeholder: UIImage = UIImage(),
              config: Config<V>? = nil) {
    let url = (urlString == nil) ? nil : URL(string: urlString!)
    self.init(url, placeholder: placeholder, config: config)
  }
  
  public var body: some View {
    let image: UIImage = imageDownloader.image ?? placeholder
    let imageView = Image(uiImage: image)
    if let config = config {
      return config(imageView).eraseToAnyView()
    }
    return imageView.eraseToAnyView()
  }
}
