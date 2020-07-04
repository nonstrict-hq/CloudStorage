// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "CloudStorage",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(name: "CloudStorage", targets: ["CloudStorage"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CloudStorage"),
    ]
)

