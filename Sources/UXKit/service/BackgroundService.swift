// © GHOZT

import UIKit

/// An object conforming to `BackgroundService` performs a background task (i.e.
/// via `UIApplication.shared.beginBackgroundTask`) and maintains a reference to
/// the resulting `UIBackgroundTaskIdentifier`.
public protocol BackgroundService: AnyObject {
  /// The identifier of the background task triggered by
  /// `UIApplication.shared.beginBackgroundTask`.
  var backgroundTaskIdentifier: UIBackgroundTaskIdentifier { get set }
}

