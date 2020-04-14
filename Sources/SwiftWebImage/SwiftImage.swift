//
//  SwiftImage.swift
//
//  Created by Cheng Zhang on 7/20/19.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import SwiftUI
import CZWebImage

public struct SwiftImage: View {
  
  @ObservedObject private var imageDownloader = SwiftImageDownloader()
  
  public typealias Config = (Image) -> AnyView
  
  private let placeholder: UIImage
  private let config: Config?
  
  /// Initializer of SwiftImage view with specified params.
  ///
  /// - Parameters:
  ///   - url: The url to download the image.
  ///   - placeholder: The placeholder image.
  ///   - config: Closure be used to config SwiftImage view.
  public init(url: String?,
              placeholder: UIImage = UIImage(),
              config: Config? = nil) {
    self.placeholder = placeholder
    self.config = config
    imageDownloader.download(url: url)
  }
  
  public var body: some View {
    let image: UIImage = imageDownloader.image ?? placeholder
    let imageView = Image(uiImage: image)
    if let config = config {
      return config(imageView)
    }
    return AnyView(imageView)
  }
  
}
