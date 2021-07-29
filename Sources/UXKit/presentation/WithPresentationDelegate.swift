// © Sybl

import BaseKit
import UIKit

private var ptr_delegate: UInt8 = 0

public protocol WithPresentationDelegate: AnyObject {
  var presentationDelegate: PresentationDelegate { get }
}

extension WithPresentationDelegate where Self: UIViewController {
  public var presentationDelegate: PresentationDelegate {
    get { return getAssociatedValue(for: self, key: &ptr_delegate) { return PresentationDelegate(self) } }
  }
}

extension UIViewController: WithPresentationDelegate {

}
