// © Sybl

import UIKit

/// A protocol that indicates the conforming object may perform background tasks by invoking
/// `UIApplication.shared.beginBackgroundTask` and maintain a reference to the resulting
/// `UIBackgroundTaskIdentifier`.
public protocol BackgroundService: AnyObject {

  /// The identifier of the background task triggered by `UIApplication.shared.beginBackgroundTask`.
  var backgroundTaskIdentifier: UIBackgroundTaskIdentifier { get set }
}

