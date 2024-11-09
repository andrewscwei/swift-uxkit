import BaseKit
import UIKit

/// Delegate object for handling UI animations based on the Core Animation
/// framework.
///
/// Some quick notes about how Core Animation works:
///   1. All animations execute inside a Core Animation transaction.
///   2. There are two types of transactions: implicit and explicit.
///   3. On threads with a run loop (i.e. the main thread), all changes to a
///      layer tree during the run loop cycle will be implicitly placed in a
///      transaction. This however excludes changes to backing layers ("backing
///      layers" are layers that back `UIView` instances, which are
///      automatically created and managed by the `UIView` instances
///      themselves). Only standalone layers manually created will be implicitly
///      placed in transactions. For example, if you created a `CALayer`
///      instance on the main thread and altered its `opacity`, this change gets
///      implicitly placed in a transaction. What this means is that every time
///      you make a change to an animatable property of a standalone layer, that
///      change gets animated because it is put in an implicit transaction. You
///      just don't notice it because the duration is `0`.
///   4. Explicit transactions are ones you create by invoking
///      `CATransaction.begin()` and `CATransaction.commit()`. All the layer
///      tree changes declared in between these two lines belong to the
///      explicitly created transaction.
///   5. Inside a `CATransaction` (explicit transaction) block, animation
///      properties specified in `CAAnimation` instances override those defined
///      by the `CATransaction` block itself. That means if you created a
///      `CABasicAnimation` of `1s` inside a `CATransaction` block, and the
///      `CATransaction` block itself has duration set to `5s`, the
///      `CABasicAnimation` will still take `1s`. If, however, you don't specify
///      a duration for the `CABasicAnimation`, it will use the
///      `CATransaction`'s duration property, which is `5s`.
///   6. There can be nested `CATransaction`s. The nested `CATransaction`'s
///      animation properties take precedence over those of the parent
///      `CATransaction`.
///
/// - SeeAlso:
///   https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html
/// - SeeAlso:
///   https://www.calayer.com/core-animation/2016/05/17/catransaction-in-depth.html
public class AnimationDelegate: NSObject, CAAnimationDelegate {

  /// Multiplier for time values (i.e. duration and delay) of all animations
  /// created by `AnimationDelegate`.
  public let timeMultiplier: Double = 1.0

  /// Default duration of all animations created by `AnimationDelegate`.
  public let defaultDuration: TimeInterval = 0.2

  /// References of registered `CAAnimation` completion handlers.
  private var completionHandlers: [String: () -> Void] = [:]

  /// Creates an explicit `CATransaction` that wraps a closure, which is
  /// supplied with a convenience method for creating animations with
  /// `AnimationDelegate` for the specified layer.
  ///
  /// - Parameters:
  ///   - layer: The layer instance.
  ///   - iterator: The closure supplied with an animation iterator for
  ///               convenience.
  public func commit(_ layer: CALayer?, iterator: (LayerAnimationIterator) -> Void) {
    guard let layer = layer else { return }
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    iterator(LayerAnimationIterator(delegate: self, layer: layer))
    CATransaction.commit()
  }

  /// Creates an explicit `CATransaction` that wraps a closure, which is
  /// supplied with a convenience method for creating animations with
  /// `AnimationDelegate` for the specified view.
  ///
  /// - Parameters:
  ///   - view: The view instance.
  ///   - iterator: The closure supplied with an animation iterator for
  ///               convenience.
  public func commit(_ view: UIView?, iterator: (LayerAnimationIterator) -> Void) {
    commit(view?.layer, iterator: iterator)
  }

  /// Creates an explicit `CATransaction` that wraps a closure, which is
  /// supplied with a convenience method for creating animations with
  /// `AnimationDelegate` for the specified `NSLayoutConstraint`.
  ///
  /// - Parameters:
  ///   - constraint: The `NSLayoutConstraint` instance.
  ///   - iterator: The closure supplied with an animation iterator for
  ///               convenience.
  public func commit(_ constraint: NSLayoutConstraint?, iterator: (ConstraintAnimationIterator) -> Void) {
    guard let constraint = constraint else { return }
    CATransaction.begin()
    iterator(ConstraintAnimationIterator(delegate: self, constraint: constraint))
    CATransaction.commit()
  }

  /// Creates a `CABasicAnimation` for a `UIView` instance (equivalent to
  /// animating the layer properties of its backing layer).
  ///
  /// - Parameters:
  ///   - view: The `UIView` instance.
  ///   - property: The property to animate, @see
  ///               `AnimationDelegate.LayerProperty`
  ///   - toValue: The value to animate to. This value is automatically
  ///              converted as best as possible to the desired type associated
  ///              to the specified animation property.
  ///   - fromValue: The value to animate from. This value is automatically
  ///                converted as best as possible to the desired type
  ///                associated to the specified animation property. Note that
  ///                if this value is not specified, the from value will be
  ///                automatically inferred from the target animation property
  ///                of the target layer's presentation layer (if there already
  ///                is an animation of the same property executing on the
  ///                layer). If not the from value will be inferred from the
  ///                target layer's model layer.
  ///   - delay: The animation delay (in seconds).
  ///   - duration: The animation duration (in seconds).
  ///   - timingFunctionName: The timing function name.
  ///   - autoreverses: Indicates if the animation automatically reverses on
  ///                   complete.
  ///   - repeatCount: Indicates the number of times the animation repeats. 0
  ///                  indicates no repeats, and any number less than 0
  ///                  indicates infinite loop.
  ///   - shouldOverwriteExisting: Indicates if the animation should overwrite
  ///                              an existing one for the same layer property.
  ///                              This defaults to `true`. If this is set to
  ///                              `false` and there already exists a running
  ///                              animation for the same layer property, this
  ///                              function does nothing.
  ///   - fillMode: The fill mode of the animation. If there is a delay in the
  ///               animation, the fill mode is automatically set to
  ///               `backwards`, given that no value is specified for this
  ///               parameter. Otherwise, the value of the parameter takes
  ///               precedence.
  ///   - completion: The handler invoked when the animation completes.
  /// - Returns: The `CABasicAnimation` instance that was created.
  @discardableResult
  public func basic(_ view: UIView?,
                    property: LayerProperty,
                    to toValue: Any,
                    from fromValue: Any? = nil,
                    delay: TimeInterval? = nil,
                    duration: TimeInterval? = nil,
                    timingFunctionName: CAMediaTimingFunctionName? = nil,
                    autoreverses: Bool? = nil,
                    repeatCount: Int? = nil,
                    shouldOverwriteExisting: Bool? = nil,
                    fillMode: CAMediaTimingFillMode? = nil,
                    completion: (() -> Void)? = nil) -> CAAnimation? {
    guard let view = view else { return nil }
    return basic(view.layer, property: property, to: toValue, from: fromValue, delay: delay, duration: duration, timingFunctionName: timingFunctionName, autoreverses: autoreverses, repeatCount: repeatCount, shouldOverwriteExisting: shouldOverwriteExisting, fillMode: fillMode, completion: completion)
  }

  /// Creates a `CABasicAnimation` for a `CALayer` instance.
  ///
  /// - Parameters:
  ///   - layer: The `CALayer` instance.
  ///   - property: The property to animate, @see
  ///               `AnimationDelegate.LayerProperty`
  ///   - toValue: The value to animate to. This value is automatically
  ///              converted as best as possible to the desired type associated
  ///              to the specified animation property.
  ///   - fromValue: The value to animate from. This value is automatically
  ///                converted as best as possible to the desired type
  ///                associated to the specified animation property. Note that
  ///                if this value is not specified, the from value will be
  ///                automatically inferred from the target animation property
  ///                of the target layer's presentation layer (if there already
  ///                is an animation of the same property executing on the
  ///                layer). If not the from value will be inferred from the
  ///                target layer's model layer.
  ///   - delay: The animation delay (in seconds).
  ///   - duration: The animation duration (in seconds).
  ///   - timingFunctionName: The timing function name.
  ///   - autoreverses: Indicates if the animation automatically reverses on
  ///                   complete.
  ///   - repeatCount: Indicates the number of times the animation repeats. 0
  ///                  indicates no repeats, and any number less than 0
  ///                  indicates infinite loop.
  ///   - shouldOverwriteExisting: Indicates if the animation should overwrite
  ///                              an existing one for the same layer property.
  ///                              This defaults to `true`. If this is set to
  ///                              `false` and there already exists a running
  ///                              animation for the same layer property, this
  ///                              function does nothing.
  ///   - fillMode: The fill mode of the animation. If there is a delay in the
  ///               animation, the fill mode is automatically set to
  ///               `backwards`, given that no value is specified for this
  ///               parameter. Otherwise, the value of the parameter takes
  ///               precedence.
  ///   - completion: The handler invoked when the animation completes.
  /// - Returns: The `CABasicAnimation` instance that was created.
  @discardableResult
  public func basic(_ layer: CALayer?,
                    property: LayerProperty,
                    to toValue: Any,
                    from fromValue: Any? = nil,
                    delay: TimeInterval? = nil,
                    duration: TimeInterval? = nil,
                    timingFunctionName: CAMediaTimingFunctionName? = nil,
                    autoreverses: Bool? = nil,
                    repeatCount: Int? = nil,
                    shouldOverwriteExisting: Bool? = nil,
                    fillMode: CAMediaTimingFillMode? = nil,
                    completion: (() -> Void)? = nil) -> CAAnimation? {
    guard let layer = layer else { return nil }

    let keyPath = property.rawValue
    let hasExisting = layer.animation(forKey: keyPath) != nil

    if hasExisting, !(shouldOverwriteExisting ?? true) { return nil }

    let currValue = hasExisting ? layer.presentation()?.value(forKey: keyPath) : layer.value(forKey: keyPath)

    var from: Any?
    var to: Any?

    switch property {
    case .zPosition:
      from = toCGFloat(fromValue ?? currValue)
      to = toCGFloat(toValue)
    case .opacity:
      from = toFloat(fromValue ?? currValue)
      to = toFloat(toValue)
    case .strokeColor,
         .fillColor,
         .backgroundColor:
      from = toCGColor(fromValue ?? currValue)
      to = toCGColor(toValue)
    default:
      from = fromValue ?? currValue
      to = toValue
    }

    layer.setValue(to, forKey: keyPath)
    layer.removeAnimation(forKey: keyPath)

    let delay = delay ?? 0
    let duration = duration ?? defaultDuration

    if delay <= 0, duration <= 0 {
      completion?()
      return nil
    }

    _log.debug { "\(NSStringFromClass(type(of: layer)))<\(ObjectIdentifier(layer).hashValue)> Animating\(completion == nil ? "" : " with completion handler")...\n↘︎ keyPath=\(keyPath)\n↘︎ to=\(to ?? "nil")" }

    let anim = CABasicAnimation(keyPath: keyPath)
    anim.fromValue = from
    anim.toValue = to
    anim.duration = duration * timeMultiplier
    anim.timingFunction = CAMediaTimingFunction(name: timingFunctionName ?? CAMediaTimingFunctionName.easeInEaseOut)
    anim.autoreverses = autoreverses ?? false

    if let repeatCount = repeatCount {
      anim.repeatCount = repeatCount < 0 ? .infinity : Float(repeatCount)
    }

    if delay > 0 {
      anim.beginTime = CACurrentMediaTime() + delay * timeMultiplier
      anim.fillMode = .both
    }
    else {
      anim.beginTime = CACurrentMediaTime()
      anim.fillMode = .removed
    }

    if let fillMode = fillMode {
      anim.fillMode = fillMode
    }

    if let completion = completion {
      let hash = toHash(anim)
      anim.delegate = self
      anim.setValue(hash, forKey: "id")
      completionHandlers[hash] = completion
    }

    layer.add(anim, forKey: keyPath)

    return anim
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
  public func basic(_ constraint: NSLayoutConstraint?,
                    to toValue: Any,
                    from fromValue: Any? = nil,
                    delay: TimeInterval? = nil,
                    duration: TimeInterval? = nil,
                    timingFunctionName: CAMediaTimingFunctionName? = nil,
                    autoreverses: Bool? = nil,
                    repeatCount: Int? = nil,
                    completion: (() -> Void)? = nil
  ) {
    guard let constraint = constraint, let viewToLayout = (constraint.firstItem as? UIView ?? constraint.secondItem as? UIView)?.superview, let toValue = toCGFloat(toValue) as? CGFloat else { return }

    if let fromValue = toCGFloat(fromValue) as? CGFloat {
      constraint.constant = fromValue
    }

    let delay = delay ?? 0
    let duration = duration ?? defaultDuration

    if delay <= 0, duration <= 0 {
      constraint.constant = toValue

      if viewToLayout.window != nil {
        viewToLayout.layoutIfNeeded()
      }

      completion?()
    }
    else {
      var options = UIView.AnimationOptions()

      if autoreverses == true { options.insert(.autoreverse) }

      if let repeatCount = repeatCount, repeatCount != 0 { options.insert(.repeat) }

      if viewToLayout.window != nil {
        viewToLayout.layoutIfNeeded()
      }

      CATransaction.begin()
      CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: timingFunctionName ?? .easeInEaseOut))
      UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
        UIView.modifyAnimations(withRepeatCount: CGFloat(repeatCount ?? 0), autoreverses: autoreverses ?? false) {}

        constraint.constant = toValue

        if viewToLayout.window != nil {
          viewToLayout.layoutIfNeeded()
        }
      }) { _ in
        completion?()
      }
      CATransaction.commit()
    }
  }

  public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard let anim = anim as? CABasicAnimation, let keyPath = anim.keyPath, let hash = anim.value(forKey: "id") as? String else { return }

    _log.debug { "<\(hash)> Animation stopped\(flag ? "" : " without finishing")\n↘︎ keyPath=\(keyPath)" }

    if flag, let completion = completionHandlers[hash] {
      completion()
    }

    completionHandlers.removeValue(forKey: hash)
  }
}
