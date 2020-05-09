// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "JSONAPIViz",
    products: [
        .library(
            name: "JSONAPIViz",
            targets: ["JSONAPIViz"]),
    ],
    dependencies: [
         .package(url: "https://github.com/mattpolzin/JSONAPI.git", from: "4.0.0-alpha.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "JSONAPIViz",
            dependencies: ["JSONAPI"]),
        .testTarget(
            name: "JSONAPIVizTests",
            dependencies: ["JSONAPIViz"]),
    ]
)
