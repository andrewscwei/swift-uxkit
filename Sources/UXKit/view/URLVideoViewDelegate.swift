// © GHOZT

import AVFoundation
import UIKit

public protocol URLVideoViewDelegate: AnyObject {

  /// Handler invoked when the video is ready to be played.
  ///
  /// - Parameters:
  ///   - videoView: The `URLVideoView` instance that invoked this delegate
  ///                method.
  func videoViewDidBecomeReadyToPlay(_ videoView: URLVideoView)

  /// Handler invoked when the video finishes playing.
  ///
  /// - Parameters:
  ///   - videoView: The `URLVideoView` instance that invoked this delegate
  ///                method.
  func videoViewDidFinishPlaying(_ videoView: URLVideoView)

  /// Handler invoked when the video playback status changes.
  ///
  /// - Parameters:
  ///   - videoView: The `URLVideoView` instance that triggered this delegate
  ///                method.
  ///   - status: The playback status that was changed to.
  func videoView(_ videoView: URLVideoView, didChangePlayStatus status: AVPlayer.TimeControlStatus)

  /// Handler invoked when the video is cleared.
  ///
  /// - Parameters:
  ///   - videoView: The `URLVideoView` instance that invoked this delegate
  ///                method.
  func videoViewDidClear(_ videoView: URLVideoView)
}

extension URLVideoViewDelegate {

  public func videoViewDidBecomeReadyToPlay(_ videoView: URLVideoView) {}

  public func videoViewDidFinishPlaying(_ videoView: URLVideoView) {}

  public func videoView(_ videoView: URLVideoView, didChangePlayStatus status: AVPlayer.TimeControlStatus) {}

  public func videoViewDidClear(_ videoView: URLVideoView) {}
}
