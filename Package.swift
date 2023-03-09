// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

enum Environment: String {
  case local
  case development
  case production

  static func get() -> Environment {
    if let envPointer = getenv("SWIFT_ENV"), let environment = Environment(rawValue: String(cString: envPointer)) {
      return environment
    }
    else if let envPointer = getenv("CI"), String(cString: envPointer) == "true" {
      return .production
    }
    else {
      return .local
    }
  }
}

var dependencies: [Package.Dependency] = [
  .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.15.4"),
]

switch Environment.get() {
case .local:
  dependencies.append(.package(path: "../BaseKit"))
case .development:
  dependencies.append(.package(name: "BaseKit", url: "https://github.com/0xGHOZT/swift-basekit", .branch("master")))
case .production:
  dependencies.append(.package(name: "BaseKit", url: "https://github.com/0xGHOZT/swift-basekit", from: "0.24.0"))
}

let package = Package(
  name: "UXKit",
  platforms: [.iOS(.v11)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "UXKit",
      targets: ["UXKit"]),
  ],
  dependencies: dependencies,
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "UXKit",
      dependencies: ["BaseKit", "SDWebImage"]),
    .testTarget(
      name: "UXKitTests",
      dependencies: ["UXKit"]),
  ]
)
