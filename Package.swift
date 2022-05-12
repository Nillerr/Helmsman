// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Helmsman",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Helmsman",
            targets: ["Helmsman"]),
    ],
    targets: [
        .target(
            name: "Helmsman",
            dependencies: []),
        .testTarget(
            name: "HelmsmanTests",
            dependencies: ["Helmsman"]),
    ]
)
