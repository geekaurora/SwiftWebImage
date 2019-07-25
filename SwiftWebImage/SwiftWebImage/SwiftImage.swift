//
//  SwiftImage.swift
//
//  Created by Cheng Zhang on 7/20/19.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import SwiftUI
import Combine
import CZWebImage

public struct SwiftImage: View {
    
    @ObjectBinding private var imageDownloader = SwiftImageDownloader()
    
    public typealias Config = (Image) -> AnyView
    
    private let config: Config?
    
    public init(imageUrl: String?, config: Config? = nil) {
        self.config = config
        imageDownloader.download(imageUrl: imageUrl)
    }
    
    public var body: some View {
        let image: UIImage = imageDownloader.image ?? UIImage()
        let imageView = Image(uiImage: image)
        if let config = config {
            return config(imageView)
        }
        return AnyView(imageView)
    }
    
}
