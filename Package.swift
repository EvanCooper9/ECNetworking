// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ECNetworking",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ECNetworking",
            targets: ["ECNetworking"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ECNetworking",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "ECNetworkingTests",
            dependencies: ["ECNetworking"],
            path: "Tests"),
    ]
)
