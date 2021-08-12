// © Sybl

import BaseKit
import UIKit

private var ptr_displayLinkDelegate: UInt8 = 0

/// An object that conforms to this protocol will automatically have access a `DisplayLinkDelegate`
/// instance. The object must manually invoke `start` on the `DisplayLinkDelegate` before it can be
/// used (and subsequently invoking `stop` for garbage collection.
public protocol WithDisplayLinkDelegate: AnyObject {

  var displayLinkDelegate: DisplayLinkDelegate { get }

  func frameWillAdvance(elapsed: TimeInterval, elapsedTotal: TimeInterval)
}

extension WithDisplayLinkDelegate {

  public var displayLinkDelegate: DisplayLinkDelegate {
    get { return getAssociatedValue(for: self, key: &ptr_displayLinkDelegate) { return DisplayLinkDelegate(self) } }
  }
}
