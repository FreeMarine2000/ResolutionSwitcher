// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "ResolutionSwitcher",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "ResolutionSwitcher",
            path: "Sources",
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"])
            ]
        )
    ]
)
