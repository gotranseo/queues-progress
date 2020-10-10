// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "QueuesProgress",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/console-kit.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0-beta.6.1"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "ConsoleKit", package: "console-kit"),
                .product(name: "Redis", package: "redis"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
            ]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
