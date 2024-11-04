import UIKit

extension NSAttributedString {
  /// Height of the attributed string given a width constraint (max width).
  ///
  /// - Parameters:
  ///   - width: The width constraint.
  ///
  /// - Returns: The height of the attributed string if it were constrained
  ///            within the provided width.
  public func height(withConstrainedWidth width: CGFloat) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

    return ceil(boundingBox.height)
  }

  /// Width of the attributed string given a height constraint (max height).
  ///
  /// - Parameters:
  ///   - height: The height constraint.
  ///
  /// - Returns: The width of the attributed string if it were constrained
  ///            within the provided height.
  public func width(withConstrainedHeight height: CGFloat) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

    return ceil(boundingBox.width)
  }
}
