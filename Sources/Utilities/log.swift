import BaseKit
import Foundation

let _log = Logger(mode: getenv("UXKIT_DEBUG") != nil ? .unified : .none, prefix: "[🚐]")
