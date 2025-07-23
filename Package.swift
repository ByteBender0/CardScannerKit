// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CardScannerKit",
    platforms: [
        .iOS(.v13) // Specify the minimum iOS version for the package
    ],
    products: [
        .library(
            name: "CardScannerKit",
            targets: ["CardScannerKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CardScannerKit",
            dependencies: []),
        .testTarget(
            name: "CardScannerKitTests",
            dependencies: ["CardScannerKit"])
    ]
)
