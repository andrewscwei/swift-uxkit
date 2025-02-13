import UIKit

/// Iterator of `NSLayoutConstraint` animations.
public class ConstraintAnimationIterator {
  let delegate: AnimationDelegate
  let constraint: NSLayoutConstraint

  public init(delegate: AnimationDelegate, constraint: NSLayoutConstraint) {
    self.delegate = delegate
    self.constraint = constraint
  }

  /// Performs a `UIView` block animation for a `NSLayoutConstraint`.
  ///
  /// - Parameters:
  ///   - constraint: The `NSLayoutConstraint` instance.
  ///   - toValue: The value to animate to. This value is automatically
  ///              converted as best as possible to the desired type.
  ///   - fromValue: The value to animate from. This value is automatically
  ///                converted as best as possible to the desired type.
  ///   - delay: The animation delay (in seconds).
  ///   - duration: The animation duration (in seconds).
  ///   - timingFunctionName: The timing function name.
  ///   - autoreverses: Indicates if the animation automatically reverses on
  ///                   complete.
  ///   - repeatCount: Indicates the number of times the animation repeats. 0
  ///                  indicates no repeats, and any number less than 0
  ///                  indicates infinite loop.
  ///   - completion: The handler invoked when the animation completes.
  public func basic(to toValue: Any,
             from fromValue: Any? = nil,
             delay: TimeInterval? = nil,
             duration: TimeInterval? = nil,
             timingFunctionName: CAMediaTimingFunctionName? = nil,
             autoreverses: Bool? = nil,
             repeatCount: Int? = nil,
             completion: ((ConstraintAnimationIterator) -> Void)? = nil) {
    delegate.basic(constraint, to: toValue, from: fromValue, delay: delay, duration: duration, timingFunctionName: timingFunctionName, autoreverses: autoreverses, repeatCount: repeatCount, completion: completion == nil ? nil : {
      completion?(self)
    })
  }
}
