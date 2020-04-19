// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSONManipulation",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(path: "./../JSONKit"),
        .package(url: "https://github.com/vapor/console-kit.git", from: "4.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/JohnSundell/Files/", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "JSONManipulation",
            dependencies: [
                .product(name: "ConsoleKit", package: "console-kit"),
                .product(name: "Files", package: "Files"),
                .product(name: "JSONKit", package: "JSONKit"),
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .testTarget(
            name: "JSONManipulationTests",
            dependencies: ["JSONManipulation"]),
    ]
)
