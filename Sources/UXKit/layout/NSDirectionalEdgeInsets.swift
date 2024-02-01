import UIKit

/// Overloaded `+` operator for two `NSDirectionalEdgeInsets` values.
///
/// - Parameters:
///   - lhs: LHS `NSDirectionalEdgeInsets` value.
///   - rhs: RHS `NSDirectionalEdgeInsets` value.
///
/// - Returns: The resulting `NSDirectionalEdgeInsets` value.
public func +(lhs: NSDirectionalEdgeInsets, rhs: NSDirectionalEdgeInsets) -> NSDirectionalEdgeInsets {
  return NSDirectionalEdgeInsets(top: lhs.top + rhs.top, leading: lhs.leading + rhs.leading, bottom: lhs.bottom + rhs.bottom, trailing: lhs.trailing + rhs.trailing)
}

/// Overloaded `-` operator for two `NSDirectionalEdgeInsets` values.
///
/// - Parameters:
///   - lhs: LHS `NSDirectionalEdgeInsets` value.
///   - rhs: RHS `NSDirectionalEdgeInsets` value.
///
/// - Returns: The resulting `NSDirectionalEdgeInsets` value.
public func -(lhs: NSDirectionalEdgeInsets, rhs: NSDirectionalEdgeInsets) -> NSDirectionalEdgeInsets {
  return NSDirectionalEdgeInsets(top: lhs.top - rhs.top, leading: lhs.leading - rhs.leading, bottom: lhs.bottom - rhs.bottom, trailing: lhs.trailing - rhs.trailing)
}

extension NSDirectionalEdgeInsets {
  /// Initializes a `NSDirectionalEdgeInsets` value with all edge inset values
  /// equal to the specified constant.
  ///
  /// - Parameters:
  ///   - constant: The constant.
  public init(withConstant constant: CGFloat) {
    self.init(top: constant, leading: constant, bottom: constant, trailing: constant)
  }

  /// Replaces old edge inset values of this `NSDirectionalEdgeInsets` with new
  /// edge inset values.
  ///
  /// - Parameters:
  ///   - top: Top edge inset value to replace (omit to retain old value).
  ///   - leading: Leading edge inset value to replace (omit to retain old
  ///              value).
  ///   - bottom: Bottom edge inset value to replace (omit to retain old value).
  ///   - trailing: Trailing edge inset value to replace (omit to retain old
  ///               value).
  ///
  /// - Returns: New `NSDirectionalEdgeInsets` struct with replaced edge inset values.
  public func replacedBy(top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil, trailing: CGFloat? = nil) -> NSDirectionalEdgeInsets {
    return NSDirectionalEdgeInsets(top: top ?? self.top, leading: leading ?? self.leading, bottom: bottom ?? self.bottom, trailing: trailing ?? self.trailing)
  }

  /// Offsets each edge inset value by the specified amount.
  ///
  /// - Parameters:
  ///   - offset: The amount to offset each edge inset value by.
  ///
  /// - Returns: New `NSDirectionalEdgeInsets` struct with offsetting edge inset
  ///            values.
  public func offsetBy(_ offset: CGFloat) -> NSDirectionalEdgeInsets {
    return NSDirectionalEdgeInsets(top: self.top + offset, leading: self.leading + offset, bottom: self.bottom + offset, trailing: self.trailing + offset)
  }
}
