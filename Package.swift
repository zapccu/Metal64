// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Metal64",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Metal64",
            targets: ["Metal64"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-numerics.git",
            from: "1.0.0"
        )
    ],
    targets: [
        // Target 1: Enthalten sind .metal Shader-Dateien
        .target(
            name: "Metal64",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics")
            ],
            cSettings: [
                .unsafeFlags([
                    "-Xmetal", "-fno-fast-math",
                    "-Xmetal", "-fno-relax-ieee"
                ])
            ]
        ),
    ]
)
