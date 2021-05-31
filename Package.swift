// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftWebImage",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftWebImage",
            type: .dynamic,
            targets: ["SwiftWebImage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/geekaurora/CZUtils.git", from: "4.1.0"),
        .package(url: "https://github.com/geekaurora/CZWebImage.git", from: "3.1.0"),
        .package(url: "https://github.com/geekaurora/SwiftUIKit.git", from: "1.0.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftWebImage",
            dependencies: ["CZUtils", "CZWebImage", "SwiftUIKit"]),
        .testTarget(
            name: "SwiftWebImageTests",
            dependencies: ["SwiftWebImage"]),
    ]
)
