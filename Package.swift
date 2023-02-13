// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyTON",
    platforms: [
        .iOS(.v13),
        .tvOS(.v11),
        .macCatalyst(.v13),
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "SwiftyTON",
            targets: ["SwiftyTON"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/attaswift/BigInt.git",
            .upToNextMajor(from: "5.3.0")
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            .upToNextMajor(from: "1.4.3")
        ),
        .package(url: "https://github.com/wollut/buffbit", .upToNextMajor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "SwiftyTON",
            dependencies: [
                "GlossyTON",
                "CryptoSwift",
                "BigInt",
                "TON3",
                "Fundamental",
            ],
            path: "Sources/SwiftyTON",
            resources: [
                .copy("Resources/Configurations"),
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
        .target(
            name: "Fundamental",
            dependencies: [
                "CryptoSwift",
                "BigInt",
                .product(name: "Buffbit", package: "buffbit"),
            ],
            path: "Sources/Fundamental",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
        .target(
            name: "GlossyTON",
            dependencies: [
                "TON",
                "OpenSSL",
            ],
            path: "Sources/GlossyTON",
            publicHeadersPath: "Include",
            cSettings: [
                .define("DEBUG", to: "1", .when(configuration: .debug)),
            ],
            cxxSettings: [
                .define("DEBUG", to: "1", .when(configuration: .debug)),
            ],
            linkerSettings: [
                .linkedLibrary("z", .when(platforms: [.macOS, .macCatalyst])),
            ]
        ),
        .target(
            name: "TON3",
            dependencies: [
                "CryptoSwift",
                "SwiftyJS",
            ],
            path: "Sources/TON3",
            resources: [
                .copy("Resources/ton3-core.bundle"),
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
        .target(
            name: "SwiftyJS",
            dependencies: [
                "CryptoSwift",
            ],
            path: "Sources/SwiftyJS",
            resources: [
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("JS_DEBUG", .when(configuration: .debug)),
            ]
        ),
        .binaryTarget(
            name: "TON",
            url: "https://github.com/labraburn/tonlib-xcframework/releases/download/v0.1.0/TON.xcframework.zip",
            checksum: "149e975b50c0451211355cfc4f4ef1fc463466cf9f47c274841325e618d1885a"
        ),
        .binaryTarget(
            name: "OpenSSL",
            url: "https://github.com/labraburn/tonlib-xcframework/releases/download/v0.1.0/OpenSSL.xcframework.zip",
            checksum: "8131452c042e6f9050dc779720213ebb7481423304dbd872fa98b5a50dba6bb8"
        ),
        .testTarget(
            name: "SwiftyTONTests",
            dependencies: ["SwiftyTON"]
        ),
        .testTarget(
            name: "FundamentalTests",
            dependencies: ["Fundamental"]
        ),
    ],
    cxxLanguageStandard: .gnucxx14
)
