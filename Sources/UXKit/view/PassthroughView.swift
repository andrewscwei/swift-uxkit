// © GHOZT

import UIKit

/// A custom `UIView` that, instead of handling touch events itself, forwards all touch events to
/// its subviews.
open class PassthroughView: UIView {

  open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    for view in subviews {
      if view.isUserInteractionEnabled, view.point(inside: convert(point, to: view), with: event) {
        return true
      }
    }

    return false
  }
}
