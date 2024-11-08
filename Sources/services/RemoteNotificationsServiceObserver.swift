import BaseKit
import Foundation

public protocol RemoteNotificationsServiceObserver: AnyObject {
  func remoteNotificationsService(_ service: RemoteNotificationsService, authorizationStatusDidChange authorizationStatus: RemoteNotificationsService.AuthorizationStatus)

  func remoteNotificationsService(_ service: RemoteNotificationsService, pushTokenDidChange pushToken: String?)
}
