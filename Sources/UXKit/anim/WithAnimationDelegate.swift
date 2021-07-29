// © Sybl

import BaseKit
import UIKit

private var ptr_animationDelegate: UInt8 = 0

public protocol WithAnimationDelegate: AnyObject {
  var animationDelegate: AnimationDelegate { get }
}

extension WithAnimationDelegate {

  public var animationDelegate: AnimationDelegate {
    get { return getAssociatedValue(for: self, key: &ptr_animationDelegate) { return AnimationDelegate() } }
  }
}

extension NSLayoutConstraint: WithAnimationDelegate {

  public func animate(iterator: (ConstraintAnimationIterator) -> Void) {
    animationDelegate.commit(self, iterator: iterator)
  }
}

extension CALayer: WithAnimationDelegate {

  public func animate(iterator: ((LayerAnimationIterator) -> Void)) {
    animationDelegate.commit(self, iterator: iterator)
  }
}

extension UIView: WithAnimationDelegate {
  
  public func animate(iterator: (LayerAnimationIterator) -> Void) {
    animationDelegate.commit(self, iterator: iterator)
  }
}
