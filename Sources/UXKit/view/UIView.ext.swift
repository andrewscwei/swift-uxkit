// © GHOZT

import UIKit

extension UIView {
  @discardableResult public func addSubview<T: UIView>(_ view: T, configure: (T) -> Void = { _ in }) -> T {
    addSubview(view)
    configure(view)

    return view
  }

  @discardableResult public func insertSubview<T: UIView>(_ view: T, at index: Int, configure: (T) -> Void = { _ in }) -> T {
    insertSubview(view, at: index)
    configure(view)

    return view
  }

  @discardableResult public func insertSubview<T: UIView>(_ view: T, aboveSubview subview: UIView, configure: (T) -> Void = { _ in }) -> T {
    insertSubview(view, aboveSubview: subview)
    configure(view)

    return view
  }

  @discardableResult public func insertSubview<T: UIView>(_ view: T, belowSubview subview: UIView, configure: (T) -> Void = { _ in }) -> T {
    insertSubview(view, belowSubview: subview)
    configure(view)

    return view
  }

  @discardableResult public func removeSubview<T: UIView>(_ view: T, unconfigure: (T) -> Void = { _ in }) -> T {
    unconfigure(view)
    view.removeFromSuperview()

    return view
  }
}
