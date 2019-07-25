//
//  SwiftImageDownloader.swift
//
//  Created by Cheng Zhang on 7/20/19.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import SwiftUI
import Combine
import CZWebImage

class SwiftImageDownloader: BindableObject {

    var didChange = PassthroughSubject<UIImage?, Never>()
    private var imageUrl: String?
    
    var image: UIImage? {
        didSet {
            didChange.send(image)
        }
    }
    
    func download(imageUrl: String?) {
        // Fetch image data and then call didChange
        self.imageUrl = imageUrl
        guard let imageUrl = imageUrl,
            let url = URL(string: imageUrl) else {
                return
        }        
        CZWebImageManager.shared.downloadImage(with: url) { (image, error, fromCache) in
            // Verify download imageUrl matches the original one
            guard self.imageUrl == imageUrl else {
                return
            }
            self.image = image
        }
        
    }
    
}
