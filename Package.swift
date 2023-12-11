// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "advent-of-code",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "AdventOfCode",
            dependencies: [
                "Shared",
                "AOC2022",
                "AOC2023",
            ]
        ),
        .target(
            name: "AOC2022",
            dependencies: ["Shared"],
            path: "Sources/2022"
        ),
        .target(
            name: "AOC2023",
            dependencies: [
                "Shared",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            path: "Sources/2023"
        ),
        .target(name: "Shared"),
        .testTarget(
            name: "AdventOfCodeTests",
            dependencies: [
                "AdventOfCode"
            ]
        )
    ]
)
