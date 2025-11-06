// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BobTheBuilder",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "BobTheBuilder",
            targets: ["BobTheBuilder"]),
    ],
    dependencies: [
        // Add Swift Package Manager dependencies here
        // Example:
        // .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
    ],
    targets: [
        .target(
            name: "BobTheBuilder",
            dependencies: [],
            path: "BobTheBuilder"),
        .testTarget(
            name: "BobTheBuilderTests",
            dependencies: ["BobTheBuilder"],
            path: "BobTheBuilderTests"),
    ]
)
