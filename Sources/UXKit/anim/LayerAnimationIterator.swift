// © GHOZT

import UIKit

/// Iterator of `CALayer` animations.
public class LayerAnimationIterator {
  let delegate: AnimationDelegate
  let layer: CALayer

  public init(delegate: AnimationDelegate, layer: CALayer) {
    self.delegate = delegate
    self.layer = layer
  }


  public func basic(_ property: AnimationDelegate.LayerProperty,
             to toValue: Any,
             from fromValue: Any? = nil,
             delay: TimeInterval? = nil,
             duration: TimeInterval? = nil,
             timingFunctionName: CAMediaTimingFunctionName? = nil,
             autoreverses: Bool? = nil,
             repeatCount: Int? = nil,
             shouldOverwriteExisting: Bool? = nil,
             fillMode: CAMediaTimingFillMode? = nil,
             completion: ((LayerAnimationIterator) -> Void)? = nil) {
    delegate.basic(layer, property: property, to: toValue, from: fromValue, delay: delay, duration: duration, timingFunctionName: timingFunctionName, autoreverses: autoreverses, repeatCount: repeatCount, shouldOverwriteExisting: shouldOverwriteExisting, fillMode: fillMode, completion: completion == nil ? nil : {
      completion?(self)
    })
  }
}
