// © Sybl

import UIKit

/// Custom `UIView` that forwards all touch events to its subviews.
open class PassthroughView: UIView {

  open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    for view in subviews {
      if view.isUserInteractionEnabled, view.point(inside: convert(point, to: view), with: event) {
        return true
      }
    }

    // TODO: This should return `false`?
    return super.point(inside: point, with: event)
  }
}
