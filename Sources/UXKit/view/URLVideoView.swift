// © GHOZT

import BaseKit
import AVFoundation
import UIKit

/// Custom `UIView` that displays a video.
public class URLVideoView: UIView, StateMachineDelegate {
  lazy public var stateMachine = StateMachine(self)

  weak public var delegate: URLVideoViewDelegate?

  private let playerLayer = AVPlayerLayer()
  public private(set) var playerItem: AVPlayerItem?
  private var imageSnapshot: UIImage?

  private var playerLayerContext = 0
  private var playerContext = 0
  private var playerItemContext = 0

  /// A weak reference to the aspect ratio constraint of this view. This is
  /// necessary in order for the view to properly resize itself based on the
  /// actual dimension of the loaded video.
  private weak var aspectRatioConstraint: NSLayoutConstraint?

  /// Specifies if the video (if any) should be played automatically on load.
  public var autoPlays: Bool = false

  /// Specifies if the video (if any) should loop indefinitely.
  public var autoLoops: Bool = true

  /// Specifies if the video is muted.
  @Stateful public var isMuted: Bool = true

  public override var contentMode: UIView.ContentMode {
    didSet {
      stateMachine.invalidate(\URLVideoView.contentMode)
    }
  }

  /// Indicates if the video (if any) is playing.
  public var isPlaying: Bool {
    get {
      guard let player = playerLayer.player else { return false }
      return player.timeControlStatus == AVPlayer.TimeControlStatus.playing
    }

    set {
      if newValue {
        playerLayer.player?.play()
      }
      else {
        playerLayer.player?.pause()
      }
    }
  }

  public var videoSize: CGSize { imageSnapshot?.size ?? .zero }

  @Stateful public var url: URL?

  override init(frame: CGRect) {
    super.init(frame: frame)
    didInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    didInit()
  }

  private func didInit() {
    backgroundColor = .clear
    contentMode = .scaleAspectFill

    layer.addSublayer(playerLayer)
    playerLayer.masksToBounds = true

    NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

    stateMachine.start()
  }

  private func willDeinit() {
    NotificationCenter.default.removeObserver(self)

    stateMachine.stop()
    clear()
  }

  deinit {
    willDeinit()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    playerLayer.frame = bounds
    playerLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
  }

  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if
      context == &playerContext,
      keyPath == #keyPath(AVPlayer.timeControlStatus)
    {
      guard let statusNumber = change?[.newKey] as? NSNumber, let status = AVPlayer.TimeControlStatus(rawValue: statusNumber.intValue) else { return }
      delegate?.videoView(self, didChangePlayStatus: status)
    }
    else if
      context == &playerItemContext,
      let playerItem = playerItem,
      playerItem == object as? AVPlayerItem,
      keyPath == #keyPath(AVPlayerItem.status)
    {
      let status: AVPlayerItem.Status

      if let statusNumber = change?[.newKey] as? NSNumber {
        status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
      } else {
        status = .unknown
      }

      switch status {
      case .readyToPlay: didBecomeReadyToPlay()
      case .failed: didFailToPlay(error: playerItem.error ?? URLVideoView.Error.unknown)
      case .unknown: break
      @unknown default: break
      }
    }
    else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  private func didBecomeReadyToPlay() {
    if autoPlays {
      playerLayer.player?.play()
    }

    updateAspectRatio()

    delegate?.videoViewDidBecomeReadyToPlay(self)
  }

  private func didFailToPlay(error: Swift.Error) {
    log(.error) { "Playing video... ERR: \(error.localizedDescription)" }
  }

  /// Handler invoked the video reaches the end.
  ///
  /// - Parameters:
  ///   - notification: The `Notification` object that triggered this handler.
  @objc private func didFinishPlaying(notification: Notification) {
    guard let playerItem = playerItem, playerItem == notification.object as? AVPlayerItem else { return }

    if autoLoops {
      playerItem.seek(to: .zero, completionHandler: nil)
    }

    delegate?.videoViewDidFinishPlaying(self)
  }

  /// Captures a still image from the current video at the specified time.
  ///
  /// - Parameters:
  ///   - time: The time of the video to capture the still image.
  ///
  /// - Returns: The captured image.
  public func captureImageFromVideo(at time: CMTime = CMTimeMake(value: 0, timescale: 1)) -> UIImage? {
    guard let url = url else { return nil }

    let asset = AVURLAsset(url: url, options: nil)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true

    guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else { return nil }

    return UIImage(cgImage: cgImage)
  }

  /// Removes the current loaded video if it exists.
  public func clear() {
    guard playerLayer.player != nil || playerItem != nil || imageSnapshot != nil else { return }

    playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    playerLayer.player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
    playerLayer.player?.pause()
    playerLayer.player = nil
    playerItem = nil

    imageSnapshot = nil

    updateAspectRatio()

    delegate?.videoViewDidClear(self)
  }

  public func update(check: StateValidator) {
    if check.isDirty(\URLVideoView.url) {
      updateVideo()
    }

    if check.isDirty(\URLVideoView.url, \URLVideoView.contentMode) {
      switch contentMode {
      case .scaleToFill:
        playerLayer.videoGravity = .resize
      case .scaleAspectFit:
        playerLayer.videoGravity = .resizeAspect
      default:
        playerLayer.videoGravity = .resizeAspectFill
      }
    }

    if check.isDirty(\URLVideoView.isMuted) {
      playerLayer.player?.isMuted = isMuted
    }
  }

  /// Updates the video with the current URL.
  private func updateVideo() {
    clear()

    guard let url = url else { return }

    playerItem = AVPlayerItem(url: url)
    playerLayer.player = AVPlayer(playerItem: playerItem)
    playerLayer.player?.actionAtItemEnd = .none
    playerLayer.player?.isMuted = isMuted
    playerLayer.player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.old, .new], context: &playerContext)

    imageSnapshot = captureImageFromVideo()

    if autoPlays {
      playerLayer.player?.play()
    }
    else {
      playerLayer.player?.pause()
    }

    playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)

    updateAspectRatio()
  }

  /// Updates the aspect ratio constraint of this view. The constraint is based
  /// on the size of the current displayed video, and automatically changes the
  /// view's height according to the aspect ratio of the video relative to the
  /// view's width.
  private func updateAspectRatio() {
    // First remove the current constraint, if it exists.
    if let oldConstraint = aspectRatioConstraint {
      removeConstraint(oldConstraint)
    }

    let size = videoSize

    guard size != .zero else { return }

    // Then apply the new constraint and lower its priority so externally
    // applied constraints can override this.
    let newConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: size.height / size.width, constant: 0)
    newConstraint.priority = UILayoutPriority(rawValue: 999)
    addConstraint(newConstraint)

    // Save a weak reference of the new constraint so it can get referred back
    // in this method.
    aspectRatioConstraint = newConstraint
  }
}
