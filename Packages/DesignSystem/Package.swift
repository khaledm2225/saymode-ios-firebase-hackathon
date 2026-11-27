// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    targets: [
        .target(
            name: "DesignSystem",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"],
            resources: [.process("Resources")]
        )
    ],
    swiftLanguageModes: [.v6]
)
