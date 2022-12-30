// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "GroutLib",
    platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9)],
    products: [
        .library(
            name: "GroutLib",
            targets: ["GroutLib"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: "GroutLib",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "GroutLibTests",
            dependencies: ["GroutLib"],
            path: "Tests"
        ),
    ]
)
