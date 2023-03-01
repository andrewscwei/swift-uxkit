// © GHOZT

import BaseKit
import UIKit

private var ptr_keyboardWillShowObserver: UInt8 = 0
private var ptr_keyboardWillHideObserver: UInt8 = 0
private var ptr_keyboardRect: UInt8 = 0

/// A `UIViewController` conforming to `KeyboardObserver` automatically gets
/// notified whenever the virtual keyboard shows or hides.
///
/// The conforming `UIViewController` must explicitly invoke
/// `beginObservingKeyboardEvents()` (i.e. in `viewWillAppear(_:)`) and
/// `endObservingKeyboardEvents()` (i.e. in `viewDidDisappear(_:)`) to subscribe
/// to and unsubscribe from the keyboard events, respectively.
public protocol KeyboardObserver: UIViewController {

  /// Handler invoked when the virtual keyboard appears. At this point, calling
  /// `getKeyboardRect(relativeTo:)` will yield the rect of the keyboard in its
  /// fully visible state.
  ///
  /// - Parameters
  ///   - rect: The rect of the keyboard when it is fully visible, relative to
  ///           the backing view of this `UIViewController`.
  func keyboardWillShow(rect: CGRect)

  /// Handler invoked when the virtual keyboard hides. At this point, calling
  /// `getKeyboardRect(relativeTo:)` will yield the rect of the keyboard in its
  /// fully hidden state, which is `nil`.
  func keyboardWillHide()
}

extension KeyboardObserver {

  private var keyboardWillShowObserver: NSObjectProtocol? {
    get { return getAssociatedValue(for: self, key: &ptr_keyboardWillShowObserver) }
    set { setAssociatedValue(for: self, key: &ptr_keyboardWillShowObserver, value: newValue) }
  }

  private var keyboardWillHideObserver: NSObjectProtocol? {
    get { return getAssociatedValue(for: self, key: &ptr_keyboardWillHideObserver) }
    set { setAssociatedValue(for: self, key: &ptr_keyboardWillHideObserver, value: newValue) }
  }

  /// `CGRect` of the device keyboard relative to the application window.
  private var keyboardRect: CGRect? {
    get { return getAssociatedValue(for: self, key: &ptr_keyboardRect) }
    set { setAssociatedValue(for: self, key: &ptr_keyboardRect, value: newValue) }
  }

  /// Returns the current rect of the virtual keyboard relative to the specified
  /// view. If the view is not provided, the returned rect will be relative to
  /// the base window. If the keyboard is not present, `nil` will be returned.
  ///
  /// - Parameter view: The view whose coordinate system is one that the
  ///                   returned rect is based on. If this is `nil`, the
  ///                   coordinate system of the base window is used instead.
  ///
  /// - Returns: The current rect of the virtual keyboard relative to specified
  ///            view, `nil` if the keyboard is not present.
  public func getKeyboardRect(relativeTo view: UIView? = nil) -> CGRect? {
    guard let keyboardRect = keyboardRect else { return nil }

    if let view = view {
      return view.convert(keyboardRect, from: nil)
    }
    else {
      return keyboardRect
    }
  }

  /// Begin listening for keyboard events.
  public func beginObservingKeyboardEvents() {
    keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { notification in
      guard let infoKey = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey], let rawFrame = (infoKey as AnyObject).cgRectValue else { return }
      self.keyboardRect = rawFrame
      self.keyboardWillShow(rect: self.view.convert(rawFrame, from: nil))
    }

    keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
      self.keyboardRect = nil
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
