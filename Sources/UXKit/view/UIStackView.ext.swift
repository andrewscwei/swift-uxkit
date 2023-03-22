// © GHOZT

import UIKit

extension UIStackView {
  public func removeAllArrangedSubviews() {
    arrangedSubviews.forEach { self.removeArrangedSubview($0) }
  }
}
