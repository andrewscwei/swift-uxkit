// © GHOZT

import UIKit

extension UIScrollView {

  /// The content offset of the scroll view at its minimum scroll position with content insets taken
  /// into account.
  public var minContentOffset: CGPoint {
    let x: CGFloat = -contentInset.left
    let y: CGFloat = -contentInset.top

    return CGPoint(x: x, y: y)
  }

  /// The content offset of the scroll view at its maximum scroll position with content insets taken
  /// into account.
  public var maxContentOffset: CGPoint {
    let x: CGFloat = max(minContentOffset.x, contentSize.width - bounds.width + contentInset.right)
    let y: CGFloat = max(minContentOffset.y, contentSize.height - bounds.height + contentInset.bottom)

    return CGPoint(x: x, y: y)
  }
}
