// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MVVM",
    platforms: [
        .iOS("26.0"),
    ],
    products: [
        .library(
            name: "MVVM",
            targets: ["MVVM"]
        ),
    ],
    targets: [
        .target(
            name: "MVVM",
            path: "Source"
        ),
    ]
)
