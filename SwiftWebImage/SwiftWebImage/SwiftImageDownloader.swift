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
    private var url: String?
    
    var image: UIImage? {
        didSet {
            didChange.send(image)
        }
    }
    
    func download(url: String?) {
        // Fetch image data and then call didChange
        self.url = url
        guard let url = url,
            let imageUrl = URL(string: url) else {
                return
        }        
        CZWebImageManager.shared.downloadImage(with: imageUrl) { (image, error, fromCache) in
            // Verify download imageUrl matches the original one
            guard self.url == url else {
                return
            }
            self.image = image
        }
        
    }
    
}
