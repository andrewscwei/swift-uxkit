import BaseKit
import UIKit

private var ptr_animationDelegate: UInt8 = 0

extension NSLayoutConstraint {
  public func animate(iterator: (ConstraintAnimationIterator) -> Void) {
    let delegate = getAssociatedValue(for: self, key: &ptr_animationDelegate) { return AnimationDelegate() }
    delegate.commit(self, iterator: iterator)
  }
}
