import BaseKit
import UIKit
import UserNotifications

/// Service for handling operations related remote notifications.
public class RemoteNotificationsService: Observable {
  public typealias Observer = RemoteNotificationsServiceObserver

  public var observers: [WeakReference<any Observer>] = []

  /// The current push token of the device.
  public private(set) var pushToken: String? = nil {
    didSet {
      guard pushToken != oldValue else { return }

      notifyObservers {
        $0.remoteNotificationsService(self, pushTokenDidChange: pushToken)
      }
    }
  }

  /// The current authorization status.
  public private(set) var authorizationStatus: AuthorizationStatus = .notDetermined {
    didSet {
      guard authorizationStatus != oldValue else { return }

      notifyObservers {
        $0.remoteNotificationsService(self, authorizationStatusDidChange: authorizationStatus)
      }
    }
  }

  public init() {
    NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// Requests for remote notifications authorization.
  ///
  /// - Parameters:
  ///   - failureHandler: Handler invoked when authorization cannot be requested.
  public func requestAuthorization(failure failureHandler: @escaping (AuthorizationStatus) -> Void = { _ in }) {
    invalidateAuthorizationStatus { status in
      switch status {
      case .notDetermined:
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { granted, error in
          if let error = error {
            _log.error("Requesting for remote notifications authorization... ERR: \(error)")
            return
          }

          guard granted else {
            _log.error("Requesting for remote notifications authorization... ERR: Not granted")
            return
          }
        }
      case .denied, .restricted:
        failureHandler(status)
      case .authorized:
        _log.debug("Requesting for remote notifications authorization... SKIP: Already granted")
      }
    }
  }

  /// Invalidates the current authorization status and fetches the most updated
  /// value. When done, the stored value will be modified.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion.
  public func invalidateAuthorizationStatus(completion: @escaping (AuthorizationStatus) -> Void = { _ in }) {
    UNUserNotificationCenter.current().getNotificationSettings() {
      let status: AuthorizationStatus

      switch $0.authorizationStatus {
      case .authorized: status = .authorized
      case .notDetermined: status = .notDetermined
      case .denied: status = .denied
      case .provisional: status = .restricted
      case .ephemeral: status = .restricted
      @unknown default: status = .denied
      }

      self.authorizationStatus = status

      completion(status)
    }
  }

  /// Invalidates the current push token if the current authorization status is
  /// `.authorized`. From this point forward, expect the app delegate's
  /// `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` or
  /// `application(_:didFailToRegisterForRemoteNotificationsWithError:)` to be
  /// invoked, which should redirect to either
  /// `didRegisterForRemoteNotificationsWithDeviceToken(_:)` or
  /// `didFailToRegisterForRemoteNotificationsWithError(_:)`, respectively.
  public func invalidatePushToken() {
    invalidateAuthorizationStatus { status in
      guard status == .authorized else {
        _log.debug("Invalidating push token... SKIP: Authorization status should be \(AuthorizationStatus.authorized), currently \(status)")
        return
      }

      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }

  /// Handler invoked in the event when app becomes active in case permissions
  /// were changed by the user while the app was in the background.
  @objc private func applicationDidBecomeActive() {
    invalidatePushToken()
  }

  /// Handler invoked by the app delegate when the app successfully registers
  /// for remote notifications with the provided device token in raw data
  /// format.
  ///
  /// - Parameters:
  ///   - token: The device token in raw data format.
  public func didRegisterForRemoteNotificationsWithDeviceToken(_ token: Data) {
    let tokenString = token.reduce("", {$0 + String(format: "%02X", $1)})

    _log.debug("Invalidating push token... OK: \(tokenString)")

    pushToken = tokenString
  }

  /// Handler invoked by the app delegate when the app fails to register for
  /// remote notifications.
  ///
  /// - Parameters:
  ///   - error: The error that caused the failure.
  public func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
    _log.error("Invalidating push token... ERR: \(error)")

    pushToken = nil
  }
}
