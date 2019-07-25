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
    
    static let list: [Feed] = [
        .init(imageUrl: "https://d37t5b145o82az.cloudfront.net/pictures/01bff78eae0870a01ed491ef86405bdf.jpg"),
        .init(imageUrl: "https://d37t5b145o82az.cloudfront.net/pictures/14729eb660b3a409368f820a053ac319.jpg"),
        .init(imageUrl: "https://d37t5b145o82az.cloudfront.net/pictures/16c9316d8f5dbccf394f20361c96a541.jpg"),
        .init(imageUrl: "https://d37t5b145o82az.cloudfront.net/pictures/297ee57338cb757d5bf359f5f0dd666f.jpg"),
        .init(imageUrl: "https://d37t5b145o82az.cloudfront.net/pictures/3a7635518ee11c02c113c6cb88f1613e.jpg")
    ]
}

struct ContentView : View {
    
    var body: some View {
        List {
            ForEach(Feed.list.identified(by: \.id)) { feed in
                SwiftImage(imageUrl: feed.imageUrl) { imageView in
                    AnyView(
                        imageView
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                    )
                }
            }
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
