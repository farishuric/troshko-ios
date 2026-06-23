// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Styleguide",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
    ],
    products: [
        .library(name: "Styleguide", targets: ["Styleguide"]),
    ],
    targets: [
        .target(
            name: "Styleguide",
            path: "Sources/Styleguide",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
