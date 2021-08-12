// © Sybl

import BaseKit
import UIKit

/// Custom `UIView` that supports hit-testing subviews outside of its bounds. Each subview must be
/// registered via `registerUnclippedSubview(_:)` in order for out-of-bounds hit-testing to take
/// effect. `UnclippedView`'s can be nested.
open class UnclippedView: UIView {

  private var unclippedSubviews: [WeakReference<UIView>] = []

  override init(frame: CGRect) {
    super.init(frame: frame)
    reinit()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    reinit()
  }

  private func reinit() {
    clipsToBounds = false
  }

  deinit {}

  public func registerUnclippedSubview(_ view: UIView) {
    if firstIndexOfUnclippedSubview(view) == nil {
      unclippedSubviews.append(WeakReference(view))
    }
  }

  public func unregisterUnclippedSubview(_ view: UIView) {
    if let index = firstIndexOfUnclippedSubview(view) {
      unclippedSubviews.remove(at: index)
    }
  }

  public func firstIndexOfUnclippedSubview(_ view: UIView) -> Int? {
    for (idx, ref) in unclippedSubviews.enumerated() {
      if ref.get() == view {
        return idx
      }
    }

    return nil
  }

  open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    for ref in unclippedSubviews {
      guard let targetView = ref.get() else { continue }

      // Convert the point to the target view's coordinate system. The target view isn't necessarily
      // the immediate subview.
      let pointForTargetView: CGPoint = targetView.convert(point, from: self)

      if targetView is UnclippedView || targetView.bounds.contains(pointForTargetView) {
        // The target view may have its view hierarchy, so call its hitTest method to return the
        // right hit-test view.
        return targetView.hitTest(pointForTargetView, with: event)
      }
    }

    return super.hitTest(point, with: event)
  }
}
