// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "LogFoundation", targets: ["LogFoundation"]),
        .library(name: "Logger", targets: ["Logger"]),
        .executable(name: "readlog", targets: ["LogReader"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0")
    ],
    targets: [
        .target(name: "LogFoundation"),
        .target(name: "Logger", dependencies: ["LogFoundation"]),
        .executableTarget(name: "LogReader", dependencies: [
            .target(name: "LogFoundation"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "DequeModule", package: "swift-collections")
        ]),
        .testTarget(name: "LogFoundationTests", dependencies: ["LogFoundation"]),
        .testTarget(name: "LoggerTests", dependencies: ["Logger"]),
    ]
)
