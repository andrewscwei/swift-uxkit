import UIKit

/// An object conforming to `BackgroundService` performs a background task (i.e.
/// via `UIApplication.shared.beginBackgroundTask`) and maintains a reference to
/// the resulting `UIBackgroundTaskIdentifier`.
public protocol BackgroundService: AnyObject {

  /// The identifier of the background task triggered by
  /// `UIApplication.shared.beginBackgroundTask`.
  var backgroundTaskIdentifier: UIBackgroundTaskIdentifier { get set }
}

extension BackgroundService {

  /// Indicates if the application is currently in the background.
  ///
  /// - Returns: `true` if the running application is in the background, `false`
  ///            otherwise.
  @MainActor
  public func isInBackground() -> Bool {
    UIApplication.shared.applicationState == .background
  }

  /// Returns the time remaining for the application to be in the background.
  ///
  /// - Returns: The time remaining in seconds.
  public func getBackgroundTaskRemainingTime() -> TimeInterval {
    UIApplication.shared.backgroundTimeRemaining
  }

  /// Begins a background task if one hasn't started yet.
  ///
  /// - Parameter name: The task name.
  ///
  /// - Returns: `true` if a new background task is created, `false` otherwise.
  public func beginBackgroundTask(with name: String) -> Bool {
    guard backgroundTaskIdentifier == UIBackgroundTaskIdentifier.invalid else { return false }

    backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: name) {
      self.endBackgroundTask()
    }

    return true
  }

  /// Ends the current running background task.
  public func endBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)

    backgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
  }
}
