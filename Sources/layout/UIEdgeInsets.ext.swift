import UIKit

/// Overloaded `+` operator for two `UIEdgeInsets` values.
///
/// - Parameters:
///   - lhs: LHS `UIEdgeInsets` value.
///   - rhs: RHS `UIEdgeInsets` value.
/// - Returns: The resulting `UIEdgeInsets` value.
public func +(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
  return UIEdgeInsets(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
}

/// Overloaded `-` operator for two `UIEdgeInsets` values.
///
/// - Parameters:
///   - lhs: LHS `UIEdgeInsets` value.
///   - rhs: RHS `UIEdgeInsets` value.
/// - Returns: The resulting `UIEdgeInsets` value.
public func -(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
  return UIEdgeInsets(top: lhs.top - rhs.top, left: lhs.left - rhs.left, bottom: lhs.bottom - rhs.bottom, right: lhs.right - rhs.right)
}

extension UIEdgeInsets {
  /// Initializes a `UIEdgeInsets` value with all edge inset values equal to the
  /// specified constant.
  ///
  /// - Parameters:
  ///   - constant: The constant.
  public init(withConstant constant: CGFloat) {
    self.init(top: constant, left: constant, bottom: constant, right: constant)
  }

  /// Replaces old edge inset values of this `UIEdgeInsets` with new edge inset
  /// values.
  ///
  /// - Parameters:
  ///   - top: Top edge inset value to replace (omit to retain old value).
  ///   - left: Left edge inset value to replace (omit to retain old value).
  ///   - bottom: Bottom edge inset value to replace (omit to retain old value).
  ///   - right: Right edge inset value to replace (omit to retain old value).
  /// - Returns: New `UIEdgeInsets` struct with replaced edge inset values.
  public func replacedBy(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> UIEdgeInsets {
    return UIEdgeInsets(top: top ?? self.top, left: left ?? self.left, bottom: bottom ?? self.bottom, right: right ?? self.right)
  }

  /// Offsets each edge inset value by the specified amount.
  ///
  /// - Parameters:
  ///   - offset: The amount to offset each edge inset value by.
  /// - Returns: New `UIEdgeInsets` struct with offsetting edge inset values.
  public func offsetBy(_ offset: CGFloat) -> UIEdgeInsets {
    return UIEdgeInsets(top: self.top + offset, left: self.left + offset, bottom: self.bottom + offset, right: self.right + offset)
  }
}
