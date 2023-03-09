// © GHOZT

import Foundation

extension PhotoLibraryService {

  /// Authorization status of photo library permission.
  public enum AuthorizationStatus: Codable, Equatable, Comparable {

    /// User explicitly denied permission.
    case denied

    /// Permission has not been requested.
    case notDetermined

    /// User explicitly granted restricted permission.
    case restricted

    /// User explicitly granted full permission.
    case authorized
  }
}
