// © Sybl

import BaseKit
import UIKit

private var ptr_keyboardWillShow: UInt8 = 0
private var ptr_keyboardWillHide: UInt8 = 0
private var ptr_keyboardFrame: UInt8 = 0

/// A `UIViewController` protocol for handling virtual keyboard show/hide events. Invoke
/// `beginObservingKeyboardEvents` (i.e. in `viewWillAppear`) to begin listening for the events and
/// `endListeneningForKeyboardEvents` (i.e. in `viewDidDisappear`) to stop.
public protocol KeyboardObserver: UIViewController {

  /// Handler invoked when the virtual keyboard shows.
  ///
  /// - Parameters
  ///   - rect: The rect of the keyboard, relative to the view of the `UIViewController`.
  func keyboardWillShow(rect: CGRect)

  /// Handler invoked when the virtual keyboard hides.
  func keyboardWillHide()
}

extension KeyboardObserver {

  private var keyboardWillShowObserver: NSObjectProtocol? {
    get { return getAssociatedValue(for: self, key: &ptr_keyboardWillShow) }
    set { setAssociatedValue(for: self, key: &ptr_keyboardWillShow, value: newValue) }
  }

  private var keyboardWillHideObserver: NSObjectProtocol? {
    get { return getAssociatedValue(for: self, key: &ptr_keyboardWillHide) }
    set { setAssociatedValue(for: self, key: &ptr_keyboardWillHide, value: newValue) }
  }

  /// `CGRect` of the device keyboard relative to the application window.
  private var keyboardFrame: CGRect? {
    get { return getAssociatedValue(for: self, key: &ptr_keyboardFrame) }
    set { setAssociatedValue(for: self, key: &ptr_keyboardFrame, value: newValue) }
  }

  /// Returns the current frame of the virtual keyboard relative to the application window. If the
  /// keyboard is not present, `nil` will be returned.
  ///
  /// - Returns: The current frame of the virtual keyboard relative to the application window, `nil`
  ///            if the keyboard is not present.
  public func getKeyboardFrame() -> CGRect? { keyboardFrame }

  /// Begin listening for keyboard events.
  public func beginObservingKeyboardEvents() {
    keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { notification in
      guard let infoKey = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey], let rawFrame = (infoKey as AnyObject).cgRectValue else { return }
      self.keyboardFrame = rawFrame
      self.keyboardWillShow(rect: self.view.convert(rawFrame, from: nil))
    }

    keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
      self.keyboardFrame = nil
      self.keyboardWillHide()
    }
  }

  /// Stop listening for keyboard events.
  public func endObservingKeyboardEvents() {
    if let keyboardWillShowObserver = keyboardWillShowObserver {
      NotificationCenter.default.removeObserver(keyboardWillShowObserver)
    }

    if let keyboardWillHideObserver = keyboardWillHideObserver {
      NotificationCenter.default.removeObserver(keyboardWillHideObserver)
    }
  }
}
