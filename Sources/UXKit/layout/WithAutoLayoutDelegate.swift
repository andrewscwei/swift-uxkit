// © Sybl

import BaseKit
import UIKit

private var ptr_autoLayoutDelegate: UInt8 = 0

public protocol WithAutoLayoutDelegate: AnyObject {

}

extension WithAutoLayoutDelegate {

  fileprivate var autoLayoutDelegate: AutoLayoutDelegate {
    get { return getAssociatedValue(for: self, key: &ptr_autoLayoutDelegate) { return AutoLayoutDelegate() } }
  }
}

extension UIView: WithAutoLayoutDelegate {

  public func autoLayout(iterator: (AutoLayoutIterator) -> Void) {
    autoLayoutDelegate.commit(self, iterator: iterator)
  }
}

extension UIViewController: WithAutoLayoutDelegate {

  /// Indicates if the view has appeared.
  public var hasViewAppeared: Bool {
    guard isViewLoaded, viewIfLoaded?.window != nil else { return false }
    return true
  }

  public func autoLayout(iterator: (AutoLayoutIterator) -> Void) {
    autoLayoutDelegate.commit(self, iterator: iterator)
  }
}
