// © GHOZT

import BaseKit
import Foundation

public protocol RemoteNotificationsServiceObserver: AnyObject {

  func remoteNotificationsService(_ service: RemoteNotificationsService, authorizationStatusDidChange authorizationStatus: RemoteNotificationsService.AuthorizationStatus)
}

extension RemoteNotificationsServiceObserver {

  public func remoteNotificationsService(_ service: RemoteNotificationsService, authorizationStatusDidChange authorizationStatus: RemoteNotificationsService.AuthorizationStatus) {}
}
