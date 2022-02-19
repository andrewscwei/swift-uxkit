// © GHOZT

import BaseKit
import UIKit

private var ptr_autoLayoutDelegate: UInt8 = 0

extension UIViewController {

  /// Indicates if the view has appeared.
  public var hasViewAppeared: Bool {
    guard isViewLoaded, viewIfLoaded?.window != nil else { return false }
    return true
  }

  public func autoLayout(iterator: (AutoLayoutIterator) -> Void) {
    let delegate = getAssociatedValue(for: self, key: &ptr_autoLayoutDelegate) { return AutoLayoutDelegate() }
    delegate.commit(self, iterator: iterator)
  }
}
