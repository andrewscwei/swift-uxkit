// © GHOZT

import BaseKit
import Foundation

public protocol PhotoLibraryServiceObserver: AnyObject {

  func photoLibraryService(_ service: PhotoLibraryService, authorizationStatusDidChange authorizationStatus: PhotoLibraryService.AuthorizationStatus)
}

extension PhotoLibraryServiceObserver {

  public func photoLibraryService(_ service: PhotoLibraryService, authorizationStatusDidChange authorizationStatus: PhotoLibraryService.AuthorizationStatus) {}
}
