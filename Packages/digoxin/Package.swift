// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Digoxin",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "Digoxin", targets: ["Digoxin"]),
    ],
    targets: [
        .target(
            name: "Digoxin",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)
