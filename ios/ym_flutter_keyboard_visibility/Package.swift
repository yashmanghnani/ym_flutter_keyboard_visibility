// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ym_flutter_keyboard_visibility",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "ym-flutter-keyboard-visibility",
            targets: ["ym_flutter_keyboard_visibility"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "ym_flutter_keyboard_visibility",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
