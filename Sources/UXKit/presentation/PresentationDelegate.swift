// © Sybl

import BaseKit
import UIKit

/// Delegate object for handling the presentation of view controllers and alert popups.
public class PresentationDelegate {

  private weak var delegator: UIViewController?

  init(_ delegator: UIViewController) {
    self.delegator = delegator
  }

  /// Presents the root view controller of a storyboard by its name.
  ///
  /// - Parameters:
  ///   - storyboardName: Name of the storyboard.
  ///   - shouldReplaceExisting: Specifies if the view controller to be presented should replace the
  ///                            currently presented view controller (if it exists). If `false` and
  ///                            there currently exists a presented view controller, this method
  ///                            will be skipped.
  public func present(_ storyboardName: String, shouldReplaceExisting: Bool = true) {
    guard let viewControllerToPresent = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() else {
      return
    }

    if delegator?.presentedViewController != nil {
      if shouldReplaceExisting {
        delegator?.dismiss(animated: true) {
          self.delegator?.present(viewControllerToPresent, animated: true, completion: nil)
        }
      }
      else {
        return
      }
    }
    else {
      delegator?.present(viewControllerToPresent, animated: true, completion: nil)
    }
  }

  /// Presents a view controller.
  ///
  /// - Parameters:
  ///   - viewControllerToPresent: View controller instance of the modal.
  ///   - shouldReplaceExisting: Specifies if the view controller to be presented should replace the
  ///                            currently presented view controller (if it exists). If `false` and
  ///                            there currently exists a presented view controller, this method
  ///                            will be skipped.
  public func present(_ viewControllerToPresent: UIViewController, shouldReplaceExisting: Bool = true) {
    if delegator?.presentedViewController != nil {
      if shouldReplaceExisting {
        delegator?.dismiss(animated: true) {
          self.delegator?.present(viewControllerToPresent, animated: true, completion: nil)
        }
      }
      else {
        return
      }
    }
    else {
      delegator?.present(viewControllerToPresent, animated: true, completion: nil)
    }
  }

  /// Presents an alert popup with the given parameters.
  ///
  /// - Parameters:
  ///   - title: Title of the popup.
  ///   - message: The message of the popup.
  ///   - actions: Array of `AlertButtonDescriptor`s, each describing an action button (from left to
  ///              right) of the alert popup.
  public func presentAlert(title: String, message: String, actions: [AlertButtonDescriptor]? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    if let actions = actions {
      for action in actions {
        alert.addAction(UIAlertAction(title: action.label, style: action.style, handler: { _ in
          action.handler?()
        }))
      }
    }
    else {
      alert.addAction(UIAlertAction(title: ltxt("LTXT_OK"), style: .default, handler: { action in
        // Do nothing, just dismiss the alert.
      }))
    }

    delegator?.present(alert, animated: true, completion: nil)
  }

  /// Presents an action sheet with the given parameters.
  ///
  /// - Parameters:
  ///   - title: Optional title of the action sheet.
  ///   - message: Optional message of the action sheet.
  ///   - actions: Array of `AlertButtonDescriptor`s, each describing an action button (from top to
  ///              bottom) of the action sheet.
  public func presentActionSheet(title: String? = nil, message: String? = nil, actions: [AlertButtonDescriptor]) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

    for action in actions {
      alert.addAction(UIAlertAction(title: action.label, style: action.style, handler: { _ in
        action.handler?()
      }))
    }

    delegator?.present(alert, animated: true, completion: nil)
  }

  /// Presents a generic yes-or-no popup that prompts the user to confirm a choice.
  ///
  /// - Parameters:
  ///   - title: Optional title of the popup.
  ///   - message: The message of the popup.
  ///   - actionLabel: Optional label of the confirm action.
  ///   - actionHandler: Optional handler of the confirm action.
  public func presentConfirmationAlert(title: String = ltxt("LTXT_CONFIRM"), message: String, actionLabel: String = ltxt("LTXT_YES"), actionHandler: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: ltxt("LTXT_CANCEL"), style: .destructive, handler: nil))
    alert.addAction(UIAlertAction(title: actionLabel, style: .default, handler: { _ in
      actionHandler?()
    }))

    delegator?.present(alert, animated: true, completion: nil)
  }

  /// Presents a generic single-button error alert.
  ///
  /// - Parameters:
  ///   - title: Optional title of the alert.
  ///   - error: The error of the alert.
  ///   - actionLabel: Optional label of the dismiss action.
  ///   - actionHandler: Optional handler of the dismiss action.
  public func presentErrorAlert(title: String = ltxt("LTXT_ERR"), error: Error? = nil, actionLabel: String = ltxt("LTXT_OK"), actionHandler: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: error?.localizedDescription ?? ltxt("LTXT_ERR_UNKNOWN"), preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: actionLabel, style: .default, handler: { _ in
      actionHandler?()
    }))

    delegator?.present(alert, animated: true, completion: nil)
  }
}
