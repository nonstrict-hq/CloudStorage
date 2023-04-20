// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CloudStorage",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v9),
    ],
    products: [
        .library(name: "CloudStorage", targets: ["CloudStorage"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CloudStorage"),
    ]
)

