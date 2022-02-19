// © GHOZT

import UIKit

/// A collection of animation timing functions.
public enum TimingModifier {

  /// Applies basic ease-in-ease-out modifier on a linear progress decimal `t`.
  ///
  /// - Parameters:
  ///   - t: The progress decimal whose value must be `0 <= t <= 1`.
  ///
  /// - Returns: The modified value.
  public static func easeInEaseOut(t: CGFloat) -> CGFloat {
    return t < 0.5 ? 2 * t * t : -1.0 + (4.0 - 2.0 * t) * t
  }
}
