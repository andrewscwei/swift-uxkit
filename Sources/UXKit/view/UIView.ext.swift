// © GHOZT

import UIKit

extension UIView {
  public func addSubview<T: UIView>(_ view: T, configure: (T) -> Void = { _ in }) {
    addSubview(view)
    configure(view)
  }

  public func insertSubview<T: UIView>(_ view: T, at index: Int, configure: (T) -> Void = { _ in }) {
    insertSubview(view, at: index)
    configure(view)
  }

  public func insertSubview<T: UIView>(_ view: T, aboveSubview subview: UIView, configure: (T) -> Void = { _ in }) {
    insertSubview(view, aboveSubview: subview)
    configure(view)
  }

  public func insertSubview<T: UIView>(_ view: T, belowSubview subview: UIView, configure: (T) -> Void = { _ in }) {
    insertSubview(view, belowSubview: subview)
    configure(view)
  }

  public func removeSubview<T: UIView>(_ view: T, unconfigure: (T) -> Void = { _ in }) {
    unconfigure(view)
    view.removeFromSuperview()
  }
}
