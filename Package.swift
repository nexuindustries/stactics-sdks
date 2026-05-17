// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Stactics",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "Stactics", targets: ["Stactics"])
    ],
    targets: [
        .target(
            name: "Stactics",
            path: "swift/Sources/Stactics"
        ),
        .testTarget(
            name: "StacticsTests",
            dependencies: ["Stactics"],
            path: "swift/Tests/StacticsTests"
        )
    ]
)
