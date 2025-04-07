// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "YooMoneyAPI",
    platforms: [.macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7), .visionOS(.v1)],
    products: [.library(name: "YooMoneyAPI", targets: ["YooMoneyAPI"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.7.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.8.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.2"),
        .package(url: "https://github.com/laconicman/OSLogLoggingMiddleware", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YooMoneyAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "OSLogLoggingMiddleware", package: "OSLogLoggingMiddleware")
            ]
        ),
        .testTarget(name: "YooMoneyAPITests",
            dependencies: ["YooMoneyAPI"]
        )
    ]
)
