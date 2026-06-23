// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Extension",
    platforms: [
        .iOS("26.0"),
    ],
    products: [
        .library(
            name: "Extension",
            targets: ["Extension"]
        ),
    ],
    targets: [
        .target(
            name: "Extension",
            path: "Source"
        ),
    ]
)
