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
                .copy("Fonts/PlusJakartaSans-Bold.ttf"),
                .copy("Fonts/PlusJakartaSans-BoldItalic.ttf"),
                .copy("Fonts/PlusJakartaSans-ExtraBold.ttf"),
                .copy("Fonts/PlusJakartaSans-ExtraBoldItalic.ttf"),
                .copy("Fonts/PlusJakartaSans-ExtraLight.ttf"),
                .copy("Fonts/PlusJakartaSans-ExtraLightItalic.ttf"),
                .copy("Fonts/PlusJakartaSans-Italic.ttf"),
                .copy("Fonts/PlusJakartaSans-Light.ttf"),
                .copy("Fonts/PlusJakartaSans-LightItalic.ttf"),
                .copy("Fonts/PlusJakartaSans-Medium.ttf"),
                .copy("Fonts/PlusJakartaSans-MediumItalic.ttf"),
                .copy("Fonts/PlusJakartaSans-Regular.ttf"),
                .copy("Fonts/PlusJakartaSans-SemiBold.ttf"),
                .copy("Fonts/PlusJakartaSans-SemiBoldItalic.ttf"),
            ]
        ),
    ]
)
