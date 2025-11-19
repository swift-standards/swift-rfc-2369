// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-rfc-2369",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "RFC 2369",
            targets: ["RFC 2369"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-rfc-3987.git", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "RFC 2369",
            dependencies: [
                .product(name: "RFC 3987", package: "swift-rfc-3987")
            ]
        ),
        .testTarget(
            name: "RFC 2369 Tests",
            dependencies: ["RFC 2369"]
        )
    ]
)

for target in package.targets {
    target.swiftSettings?.append(
        contentsOf: [
            .enableUpcomingFeature("MemberImportVisibility")
        ]
    )
}
