// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tik-Tok-TTS-Bot",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/SketchMaster2001/Swiftcord", .branch("master"))
    ],
    targets: [
        .executableTarget(
            name: "Tik-Tok-TTS-Bot",
            dependencies: ["Swiftcord"])
    ]
)
