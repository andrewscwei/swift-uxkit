import UIKit

/// A type conforming to `Measurable` has a statically computable `CGSize` based
/// on some arbitrary attributes.
public protocol Measurable: AnyMeasurable  {
  /// Attributes used to compute the size of the conforming object.
  associatedtype MeasurableParams

  /// Returns the computed size that fits this object based on a set of
  /// attributes.
  ///
  /// - Parameters:
  ///   - params: Attributes that affect the calculation of the size.
  /// - Returns: The computed `CGSize`.
  static func sizeThatFits(with params: MeasurableParams?) -> CGSize
}

extension Measurable {
  public func sizeThatFits() -> CGSize {
    return Self.sizeThatFits(with: nil)
  }
}
