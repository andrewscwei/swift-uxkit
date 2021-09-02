// © Sybl

import UIKit

extension String {

  /// Height of the attributed string given a font and width constraint (max width).
  ///
  /// - Parameters:
  ///   - width: The width constraint.
  ///   - font: The font.
  ///
  /// - Returns: The height of the string if it were constrained within the provided width.
  public func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

    return ceil(boundingBox.height)
  }

  /// Width of the string given a font and height constraint (max height).
  ///
  /// - Parameters:
  ///   - height: The height constraint.
  ///   - font: The font.
  ///
  /// - Returns: The width of the string if it were constrained within the provided height.
  public func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

    return ceil(boundingBox.width)
  }
}
