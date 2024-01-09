// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LookheartPackage",
    products: [
        .library(
            name: "LookheartPackage",
            targets: ["LookheartPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danielgindi/Charts.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(
            name: "LookheartPackage",
            dependencies: [
                "Charts",
                "Alamofire"
            ]
        ),
        .testTarget(
            name: "LookheartPackageTests",
            dependencies: ["LookheartPackage"]),
    ]
)
