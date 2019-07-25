//
//  ContentView.swift
//  SwiftWebImageDemo
//
//  Created by Cheng Zhang on 2019/7/25.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import SwiftUI
import SwiftWebImage

struct Feed: Identifiable {
    let id: UUID = UUID()
    let imageUrl: String
    
    static let sample = Feed(imageUrl: "https://d37t5b145o82az.cloudfront.net/pictures/01bff78eae0870a01ed491ef86405bdf.jpg")
}

struct ContentView : View {
    
    var body: some View {
        SwiftImage(imageUrl: Feed.sample.imageUrl) { imageView in
            AnyView(
                imageView
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            )
        }
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
