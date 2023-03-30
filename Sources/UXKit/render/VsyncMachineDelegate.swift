// © GHOZT

import UIKit

public protocol VsyncMachineDelegate: AnyObject {
  /// Handler invoked whenever the epoch changes.
  ///
  /// - Parameters:
  ///   - vsyncMachine: The invoking `VsyncMachine` instance.
  ///   - epoch: Epoch (in ms).
  func vsyncMachine(_ vsyncMachine: VsyncMachine, epochDidChange epoch: TimeInterval?)

  /// Handler invoked whenever the time elapses.
  ///
  /// - Parameters:
  ///   - vsyncMachine: The invoking `VsyncMachine` instance.
  ///   - elapsedTimeSinceEpoch: Elapsed time since epoch (in ms).
  func vsyncMachine(_ vsyncMachine: VsyncMachine, elapsedTimeSinceEpochDidChange elapsedTimeSinceEpoch: TimeInterval)

  /// Handler invoked whenever a frame has advanced in the internal
  /// `DisplayLink` of the `VsyncMachine` instanace.
  ///
  /// - Parameters:
  ///   - vsyncMachine: The invoking `VsyncMachine` instance`.
  ///   - elapsedTime: The time elapsed (in ms) since the last invocation of
  ///                  this method.
  func vsyncMachineWillAdvanceFrame(_ vsyncMachine: VsyncMachine, elapsedTimeSinceLastFrame elapsedTime: TimeInterval)
}

extension VsyncMachineDelegate {
  public func vsyncMachine(_ vsyncMachine: VsyncMachine, epochDidChange epoch: TimeInterval?) {}
  public func vsyncMachine(_ vsyncMachine: VsyncMachine, elapsedTimeSinceEpochDidChange elapsedTimeSinceEpoch: TimeInterval) {}
  public func vsyncMachineWillAdvanceFrame(_ vsyncMachine: VsyncMachine, elapsedTimeSinceLastFrame elapsedTime: TimeInterval) {}
}
