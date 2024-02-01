import UIKit

/// Delegate object for defining and applying auto layout rules to `UIView` and `UIViewController`.
class AutoLayoutDelegate {
  /// Applies auto layout rules to a `UIViewController`'s backing `UIView` using an
  /// `AutoLayoutIterator`.
  ///
  /// - Parameters:
  ///   - viewController: The `UIViewController` to apply auto layout rules to.
  ///   - iterator: The `AutoLayoutIterator`.
  func commit(_ viewController: UIViewController?, iterator: (AutoLayoutIterator) -> Void) {
    guard let view = viewController?.view else { return }
    iterator(AutoLayoutIterator(view))
  }

  /// Applies auto layout rules to a `UIView` using an `AutoLayoutIterator`.
  ///
  /// - Parameters:
  ///   - view: The `UIView` to apply auto layout rules to.
  ///   - iterator: The `AutoLayoutIterator`.
  func commit(_ view: UIView?, iterator: (AutoLayoutIterator) -> Void) {
    guard let view = view else { return }
    iterator(AutoLayoutIterator(view))
  }
}
