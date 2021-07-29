// © Sybl

import UIKit

class AutoLayoutDelegate {

  init() {}

  func commit(_ viewController: UIViewController?, iterator: (AutoLayoutIterator) -> Void) {
    guard let view = viewController?.view else { return }
    iterator(AutoLayoutIterator(view))
  }

  func commit(_ view: UIView?, iterator: (AutoLayoutIterator) -> Void) {
    guard let view = view else { return }
    iterator(AutoLayoutIterator(view))
  }
}
