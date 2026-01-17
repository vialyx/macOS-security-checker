// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "macOS-security-checker",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "macOS-security-checker", targets: ["SecurityChecker"])
    ],
    targets: [
        .executableTarget(
            name: "SecurityChecker",
            dependencies: [],
            path: "Sources",
            swiftSettings: [
                .unsafeFlags(["-suppress-warnings"], .when(configuration: .release))
            ]
        )
    ]
)
