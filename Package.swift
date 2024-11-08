// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "UXKit",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "UXKit",
      targets: [
        "UXKit",
      ]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.0.0"),
    .package(path: "../BaseKit"),
//    .package(url: "https://github.com/andrewscwei/swift-basekit.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "UXKit",
      dependencies: [
//        .product(name: "BaseKit", package: "swift-basekit"),
        "BaseKit",
        "SDWebImage",
      ],
      path: "Sources"
//      swiftSettings: [.define("UXKIT_DEBUG")]
    ),
    .testTarget(
      name: "UXKitTests",
      dependencies: [
        "UXKit",
      ],
      path: "Tests"
    ),
  ]
)
