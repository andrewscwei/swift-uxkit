// © Sybl

import BaseKit
import UIKit

public class DisplayLinkDelegate {

  private weak var delegator: WithDisplayLinkDelegate?

  /// Local `CADisplayLink` instance.
  private var displayLink: CADisplayLink?

  /// The time (in milliseconds) of which the most recently created display link started.
  private var epoch: TimeInterval?

  init(_ delegator: WithDisplayLinkDelegate) {
    self.delegator = delegator
  }

  /// Creates and starts a new display link. Resets epoch.
  public func start() {
    stop()

    displayLink = CADisplayLink(target: self, selector: #selector(frameWillAdvance))
    displayLink?.isPaused = false
    displayLink?.preferredFramesPerSecond = 60
    displayLink?.add(to: .current, forMode: .common)
  }

  /// Stops and destroys the active display link.
  public func stop() {
    displayLink?.invalidate()
    displayLink = nil
    reset()
  }

  /// Pauses the current active display link. The display link is not removed, but merely paused, so
  /// it can be resumed at a later point.
  public func pause() {
    displayLink?.isPaused = true
  }

  /// Resumes the current active display link if it was previously paused.
  public func resume() {
    displayLink?.isPaused = false
  }

  /// Resets epoch value, which consequently resets the total elapsed time of the display link.
  public func reset() {
    epoch = nil
  }

  /// Handler invoked on every frame advancement for the duration of the current active display
  /// link.
  ///
  /// - Parameters:
  ///   - displayLink: The current active display link.
  @objc public func frameWillAdvance(displayLink: CADisplayLink) {
    let elapsed = displayLink.targetTimestamp - displayLink.timestamp
    let epoch = self.epoch ?? displayLink.targetTimestamp

    if self.epoch == nil {
      self.epoch = epoch
    }

    delegator?.frameWillAdvance(elapsed: elapsed, elapsedTotal: displayLink.targetTimestamp - epoch)
  }
}
