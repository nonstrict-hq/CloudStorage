// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CloudStorage",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .tvOS(.v14),
    ],
    products: [
        .library(name: "CloudStorage", targets: ["CloudStorage"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CloudStorage"),
    ]
)

