// © GHOZT

import UIKit

extension UIStackView {
  @discardableResult public func addArrangedSubview<T: UIView>(_ view: T, configure: (T) -> Void = { _ in }) -> T {
    addArrangedSubview(view)
    configure(view)

    return view
  }

  @discardableResult public func removeArrangedSubview<T: UIView>(_ view: T, unconfigure: (T) -> Void = { _ in }) -> T {
    unconfigure(view)
    removeArrangedSubview(view)

    return view
  }

  public func removeAllArrangedSubviews() {
    arrangedSubviews.forEach { self.removeArrangedSubview($0) }
  }
}
