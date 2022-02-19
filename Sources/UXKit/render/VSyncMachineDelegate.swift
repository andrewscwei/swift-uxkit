// © GHOZT

import UIKit

/// An object conforming to `VSyncMachineDelegate` will assume the delegate of a `VSyncMachine`,
/// receiving frame updates from the `DisplayLink` upon invoking `start` on the `VSyncMachine`
/// instance. The object must also invoke `stop` on the `VSyncMachine` for optimal memory
/// management.
public protocol VSyncMachineDelegate: AnyObject {

  /// The internal `VSyncMachine` instance.
  var vsyncMachine: VSyncMachine { get }

  /// Handler invoked whenever a frame has advanced in the `DisplayLink`.
  ///
  /// - Parameters:
  ///   - elapsed: The time elapsed (in milliseconds) since the last
  ///              `frameWillAdvance(elapsed:elapsedTotal:)`.
  ///   - elapsedTotal: The total time elapsed (in milliseconds) since `epoch`.
  func frameWillAdvance(elapsed: TimeInterval, elapsedTotal: TimeInterval)
}
