// © GHOZT

import BaseKit
import UIKit

extension AnimationDelegate {

  /// Converts an animation instance to a unique hash value.
  ///
  /// - Parameters:
  ///   - anim: The `CAAnimation` instance.
  ///
  /// - Returns: The unique hash.
  func toHash(_ anim: CAAnimation) -> String {
    return "\(ObjectIdentifier(anim).hashValue)"
  }

  /// Converts any value to a float if possible, returns `nil` otherwise.
  ///
  /// - Parameters:
  ///   - value: The value to convert.
  ///
  /// - Returns: The converted value or `nil` if the conversion was not
  ///            possible.
  func toFloat(_ value: Any?) -> Any? {
    if let value = value as? CGFloat { return Float(value) }
    if let value = value as? Double { return Float(value) }
    if let value = value as? Int { return Float(value) }
    return value
  }

  /// Converts any value to a `CGFloat` if possible, returns `nil` otherwise.
  ///
  /// - Parameters:
  ///   - value: The value to convert.
  ///
  /// - Returns: The converted value or `nil` if the conversion was not
  ///            possible.
  func toCGFloat(_ value: Any?) -> Any? {
    if let value = value as? Float { return CGFloat(value) }
    if let value = value as? Double { return CGFloat(value) }
    if let value = value as? Int { return CGFloat(value) }
    return value
  }

  /// Converts any value to a `CGColor` if possible, return `nil` otherwise.
  ///
  /// - Parameters:
  ///   - value: The value to convert.
  ///
  /// - Returns: The converted value or `nil` if the conversion was not
  ///            possible.
  func toCGColor(_ value: Any?) -> Any? {
    if let value = value as? UIColor { return value.cgColor }
    return value
  }
}
