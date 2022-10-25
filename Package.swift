// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RASPKit",
    products: [
        .library(
            name: "RASPKit",
            targets: ["RASPKit"]
        ),
    ],
    dependencies: [
        // None.
    ],
    targets: [
        .target(
            name: "RASPKit",
            dependencies: []
        ),
        .testTarget(
            name: "RASPKitTests",
            dependencies: ["RASPKit"]
        ),
    ]
)
