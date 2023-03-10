// © GHOZT

import UIKit

/// A `UIResponder` conforming to `AnyMeasurable` has a computable `CGSize`.
public protocol AnyMeasurable: UIResponder {
  /// Returns the computed size that fits this object.
  ///
  /// - Returns: The computed `CGSize` struct.
  func sizeThatFits() -> CGSize
}
