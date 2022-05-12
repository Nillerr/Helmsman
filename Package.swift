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
    dependencies: [
        .package(url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.4")
    ],
    targets: [
        .target(
            name: "Helmsman",
            dependencies: [.product(name: "Introspect", package: "SwiftUI-Introspect")]),
        .testTarget(
            name: "HelmsmanTests",
            dependencies: ["Helmsman"]),
    ]
)
