// © GHOZT

import UIKit

extension UIView {
  public func addSubview<T: UIView>(_ view: T, configure: (T) -> Void = { _ in }) {
    addSubview(view)
    configure(view)
  }

  public func removeSubview<T: UIView>(_ view: T, unconfigure: (T) -> Void = { _ in }) {
    unconfigure(view)
    view.removeFromSuperview()
  }
}
