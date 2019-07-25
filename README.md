# SwiftWebImage

![Swift Version](https://img.shields.io/badge/swift-5.0-orange.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/CZUtils.svg?style=flat)](http://cocoapods.org/pods/CZUtils)
[![Platform](https://img.shields.io/cocoapods/p/CZUtils.svg?style=flat)](http://cocoapods.org/pods/CZUtils)

Progressive concurrent image downloader for SwiftUI BindingObject.

With neat APIs, performant LRU mem/disk cache. Supports cropping image in background thread.
 
### Simple Usage

Just `import SwiftWebImage` and set `imageUrl` for `SwiftImage`:

```swift
import SwiftWebImage

var body: some View {
    List {
        ForEach(Feed.list.identified(by: \.id)) { feed in
        	  // Set `imageUrl` for `SwiftImage`
            SwiftImage(imageUrl: feed.imageUrl)
        }
    }
}                        
```

Framework will automatically load Image with `@ObjectBinding` data once download completes.

#### How to config Image? 
Trailing `config` block of `SwiftImage` is used for Image configuration:

```swift
var body: some View {
    List {
        ForEach(Feed.list.identified(by: \.id)) { feed in
            SwiftImage(imageUrl: feed.imageUrl) { imageView in
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