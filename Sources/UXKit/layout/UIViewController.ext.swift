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

  public func addChild<T: UIViewController, V: UIView>(_ viewController: T, toView view: V, configure: (T) -> Void = { _ in }) {
    addChild(viewController)

    if let stackView = view as? UIStackView {
      stackView.addArrangedSubview(viewController.view)
    }
    else {
      view.addSubview(viewController.view)
    }

    configure(viewController)

    viewController.didMove(toParent: self)
  }

  public func removeChild<T: UIViewController>(_ viewController: T, unconfigure: (T) -> Void = { _ in }) {
    viewController.willMove(toParent: nil)
    unconfigure(viewController)

    if let stackView = viewController.view.superview as? UIStackView {
      stackView.removeArrangedSubview(viewController.view)
    }
    else {
      viewController.view.removeFromSuperview()
    }

    viewController.removeFromParent()
  }
}
