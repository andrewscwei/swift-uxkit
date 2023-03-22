// © GHOZT

import BaseKit
import Photos
import UIKit

public class PhotoLibraryService: Observable {
  public typealias Observer = PhotoLibraryServiceObserver

  /// Gets the photo library authorization status.
  public var authorizationStatus: AuthorizationStatus {
    let status = PHPhotoLibrary.authorizationStatus()

    switch status {
    case .authorized: return .authorized
    case .notDetermined: return .notDetermined
    case .restricted: return .restricted
    case .denied: return .denied
    default: return .notDetermined
    }
  }

  public init() {}

  /// Requests for photo library authorization.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion.
  public func requestAuthorization(failure failureHandler: @escaping (AuthorizationStatus) -> Void = { _ in }) {
    let status = authorizationStatus

    switch status {
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization { (_) in
        DispatchQueue.main.async {
          self.notifyObservers { $0.photoLibraryService(self, authorizationStatusDidChange: self.authorizationStatus) }
        }
      }
    case .restricted,
         .denied:
      failureHandler(status)
//      DispatchQueue.main.async {
//        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//      }
    default:
      break
    }
  }
}
