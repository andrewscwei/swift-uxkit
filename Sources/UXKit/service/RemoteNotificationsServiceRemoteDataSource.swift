// © GHOZT

import Foundation

public protocol RemoteNotificationsServiceRemoteDataSource {

  func write(_ value: String, completion: @escaping (Result<String, Error>) -> Void)

  func delete(completion: @escaping (Result<Void, Error>) -> Void)
}
