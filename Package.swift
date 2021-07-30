// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

enum Environment: String {
  static let `default`: Environment = .local

  case local
  case development
  case production

  static func get() -> Environment {
    if let envPointer = getenv("CI"), String(cString: envPointer) == "true" {
      return .production
    }
    else if let envPointer = getenv("SWIFT_ENV") {
      let env = String(cString: envPointer)
      return Environment(rawValue: env) ?? .default
    }
    else {
      return .default
    }
  }
}

var dependencies: [Package.Dependency] = [
  .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.11.1"),
]

switch Environment.get() {
case .local:
  dependencies.append(.package(path: "../BaseKit"))
case .development:
  dependencies.append(.package(url: "git@github.com:sybl/swift-basekit", .branch("main")))
case .production:
  dependencies.append(.package(url: "git@github.com:sybl/swift-basekit", from: "0.1.0"))
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
