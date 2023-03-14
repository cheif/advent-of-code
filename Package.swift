// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "advent-of-code",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "advent-of-code",
            targets: ["advent-of-code"]),
    ],
    targets: [
        .target(
            name: "advent-of-code",
            dependencies: [])
    ]
)
