// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyNewExecutable",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(name: "MoggedVideo", targets: ["MoggedVideo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/StreamUI/StreamUI.git", from: "0.1.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.21.0"),

    ],
    targets: [
        .executableTarget(
            name: "VideoRecorder",
            dependencies: [
                "MoggedVideo",
                .product(name: "StreamUI", package: "StreamUI"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/VideoRecorder"
        ),

        .target(
            name: "MoggedVideo",
            dependencies: [
                .product(name: "StreamUI", package: "StreamUI"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
            ],
            path: "Sources/MoggedVideo"
        ),
    ]
)
