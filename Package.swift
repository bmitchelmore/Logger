// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "Logger", targets: ["Logger"]),
    ],
    targets: [
        .target(name: "Logger"),
        .testTarget(name: "LoggerTests", dependencies: ["Logger"]),
    ]
)
