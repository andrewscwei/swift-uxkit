// © Sybl

import UIKit

/// A `UIResponder` protocol that computes its own `CGSize`.
public protocol AnySizeComputable: UIResponder {

  /// Returns the computed size that fits this object.
  ///
  /// - Returns: The computed `CGSize` struct.
  func sizeThatFits() -> CGSize
}
