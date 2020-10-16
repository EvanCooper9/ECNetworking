// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ECNetworking",
    products: [
        .library(
            name: "ECNetworking",
            targets: ["ECNetworking"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.0.0-rc.1"))
    ],
    targets: [
        .target(
            name: "ECNetworking",
            dependencies: ["RxSwift"],
            path: "Sources"),
        .testTarget(
            name: "ECNetworkingTests",
            dependencies: ["ECNetworking"]),
    ]
)
