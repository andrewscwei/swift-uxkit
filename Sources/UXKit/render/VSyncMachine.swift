// © GHOZT

import UIKit

public class VSyncMachine {

  private weak var delegate: VSyncMachineDelegate?

  /// Local `CADisplayLink` instance.
  private var displayLink: CADisplayLink?

  /// The time (in milliseconds) of which the most recently created display link
  /// started.
  private var epoch: TimeInterval?

  /// The time (in milliseconds) elapsed since this `VSyncMachine` started.
  public private(set) var elapsedTime: TimeInterval = 0

  public init(_ delegate: VSyncMachineDelegate) {
    self.delegate = delegate
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

  /// Pauses the current active display link. The display link is not removed,
  /// but merely paused, so it can be resumed at a later point.
  public func pause() {
    displayLink?.isPaused = true
  }

  /// Resumes the current active display link if it was previously paused.
  public func resume() {
    displayLink?.isPaused = false
  }

  /// Resets epoch value, which consequently resets the total elapsed time of
  /// the display link.
  public func reset() {
    epoch = nil
    elapsedTime = 0
  }

  /// Handler invoked on every frame advancement for the duration of the current
  /// active display link.
  ///
  /// - Parameters:
  ///   - displayLink: The current active display link.
  @objc public func frameWillAdvance(displayLink: CADisplayLink) {
    let elapsedSinceLastFrame = displayLink.targetTimestamp - displayLink.timestamp
    let epoch = self.epoch ?? displayLink.targetTimestamp

    if self.epoch == nil {
      self.epoch = epoch
    }

    elapsedTime = displayLink.targetTimestamp - epoch

    delegate?.frameWillAdvance(elapsed: elapsedSinceLastFrame, elapsedTotal: elapsedTime)
  }
}
