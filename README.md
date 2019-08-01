# SwiftWebImage

![Swift Version](https://img.shields.io/badge/swift-5.0-orange.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/CZUtils.svg?style=flat)](http://cocoapods.org/pods/CZUtils)
[![Platform](https://img.shields.io/cocoapods/p/CZUtils.svg?style=flat)](http://cocoapods.org/pods/CZUtils)

Progressive concurrent image downloader for SwiftUI BindingObject, with neat API and performant LRU mem/disk cache.
 
### Simple Usage

Just `import SwiftWebImage` and set `url` for `SwiftImage`:

```swift
import SwiftWebImage

var body: some View {
    List {
        ForEach(Feed.list.identified(by: \.id)) { feed in
            // Set `url` for `SwiftImage`
            SwiftImage(url: feed.imageUrl)
        }
    }
}                       
```

Framework will automatically load Image with `@ObjectBinding` data once download completes.

#### How to config ImageView? 
Trailing `config` block of `SwiftImage` is used for underlying ImageView configuration:

```swift
var body: some View {
    List {
        ForEach(Feed.list.identified(by: \.id)) { feed in
            SwiftImage(url: feed.imageUrl) { imageView in
                AnyView(
                    imageView
                        .frame(height: 300)
                        .clipped()
                )
            }
        }
    }
}
```

### Demo

<img src="./Docs/CZInstagram.gif">