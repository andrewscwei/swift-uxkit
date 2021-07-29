// © Sybl

import UIKit

public class ConstraintAnimationIterator {
  
  let delegate: AnimationDelegate
  let constraint: NSLayoutConstraint

  public init(delegate: AnimationDelegate, constraint: NSLayoutConstraint) {
    self.delegate = delegate
    self.constraint = constraint
  }

  public func basic(to toValue: Any,
             from fromValue: Any? = nil,
             delay: TimeInterval? = nil,
             duration: TimeInterval? = nil,
             timingFunctionName: CAMediaTimingFunctionName? = nil,
             autoreverses: Bool? = nil,
             repeatCount: Int? = nil,
             completion completionHandler: ((ConstraintAnimationIterator) -> Void)? = nil) {
    delegate.basic(constraint, to: toValue, from: fromValue, delay: delay, duration: duration, timingFunctionName: timingFunctionName, autoreverses: autoreverses, repeatCount: repeatCount, completion: completionHandler == nil ? nil : {
      completionHandler?(self)
    })
  }
}
