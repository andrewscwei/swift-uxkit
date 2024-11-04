// swift-tools-version:5.5

import PackageDescription

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

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
    .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.19.4"),
    .package(name: "BaseKit", url: "https://github.com/andrewscwei/swift-basekit", from: "0.35.0"),
  ],
  targets: [
    .target(
      name: "UXKit",
      dependencies: [
        "BaseKit",
        "SDWebImage",
      ],
      path: "Sources"
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
