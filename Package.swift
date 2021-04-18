// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SwipeableTabBarController",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "SwipeableTabBarController", targets: ["SwipeableTabBarController"]),
    ],
    targets: [
        .target(
            name: "SwipeableTabBarController",
            path: "./Sources"
        )
    ]
)
