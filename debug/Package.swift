// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "debug",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(name: "debug", targets: ["debug"]),
    ],
    dependencies: [
        .package(
            name: "mongo-swift-driver",
            url: "https://github.com/mongodb/mongo-swift-driver.git",
            .upToNextMajor(from: "1.1.0")
        ),
        .package(url: "https://github.com/mongodb/swift-bson.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/apple/swift-nio", .upToNextMajor(from: "2.26.0"))
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "debug",
            dependencies: [
                .product(name: "MongoSwiftSync", package: "mongo-swift-driver"),
                .product(name: "SwiftBSON", package: "swift-bson"),
            ]),
    ]
)
