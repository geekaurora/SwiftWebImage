# SwiftWebImage

![Swift Version](https://img.shields.io/badge/swift-5.0-orange.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/CZUtils.svg?style=flat)](http://cocoapods.org/pods/CZUtils)
[![Platform](https://img.shields.io/cocoapods/p/CZUtils.svg?style=flat)](http://cocoapods.org/pods/CZUtils)

Progressive concurrent image downloader for SwiftUI, with neat API and performant LRU mem/disk cache.
 
### Simple Usage

Just `import SwiftWebImage` and set `url` for `SwiftImage`:

```swift
SwiftImage<Image>(url: imageUrl)                   
```

Framework will automatically load Image with `@ObservedObject` data once download completes.

#### How to config ImageView? 
Trailing `config` block of `SwiftImage` is used for underlying ImageView configuration:

```swift
SwiftImage(url: imageUrl) { imageView in
  imageView
    .resizable()
    .aspectRatio(1, contentMode: .fit)
}
```

### Demo

<img src="https://media.giphy.com/media/jSWYS99p1rXe9nSCtp/giphy.gif">
