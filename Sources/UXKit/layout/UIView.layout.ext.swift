// © GHOZT

import BaseKit
import UIKit

private var ptr_autoLayoutDelegate: UInt8 = 0

extension UIView {
  public func autoLayout(iterator: (AutoLayoutIterator) -> Void) {
    let delegate = getAssociatedValue(for: self, key: &ptr_autoLayoutDelegate) { return AutoLayoutDelegate() }
    delegate.commit(self, iterator: iterator)
  }
}
