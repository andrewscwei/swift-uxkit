// © Sybl

import BaseKit
import UIKit

private var ptr_presentationDelegate: UInt8 = 0

extension UIViewController {

  public var presentationDelegate: PresentationDelegate {
    get { return getAssociatedValue(for: self, key: &ptr_presentationDelegate) { return PresentationDelegate(self) } }
  }
}
