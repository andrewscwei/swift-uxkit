// © GHOZT

import BaseKit
import UIKit

/// A custom `UIView` that handles hit-testing of subviews outside of its bounds. For this to work,
/// each subview (that wishes to have out-of-bounds hit-testing detected) must be registered via
/// `registerUnclippedSubview(_:)`. `UnclippedView`'s can be nested.
open class UnclippedView: UIView {

  private var unclippedSubviews: [WeakReference<UIView>] = []

  override init(frame: CGRect) {
    super.init(frame: frame)
    didInit()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    didInit()
  }

  private func didInit() {
    clipsToBounds = false
  }

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
