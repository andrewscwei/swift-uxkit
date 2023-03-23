// © GHOZT

import UIKit

extension UIStackView {
  public func addArrangedSubview<T: UIView>(_ view: T, configure: (T) -> Void = { _ in }) {
    addArrangedSubview(view)
    configure(view)
  }

  public func removeArrangedSubview<T: UIView>(_ view: T, unconfigure: (T) -> Void = { _ in }) {
    unconfigure(view)
    removeArrangedSubview(view)
  }

  public func removeAllArrangedSubviews() {
    arrangedSubviews.forEach { self.removeArrangedSubview($0) }
  }
}
