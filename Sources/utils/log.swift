import BaseKit
import Foundation

let _log = Log(mode: getenv("UXKIT_DEBUG") != nil ? .unified : .none, prefix: "[🚐]")
