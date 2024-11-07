import BaseKit
import Foundation

/// A `LiveData` type that wraps a value `T` from a transformed `Repository`
/// value `R`.
public class RepositoryLiveData<T: Equatable, R: Repository>: LiveData<T>, RepositoryObserver {
  private let map: (R.DataType, T?) -> T?

  let repository: R

  /// Creates a `RepositoryLiveData` instance, assigning its value to a mapped
  /// `Repository` value. If unsynced, the initial value is `nil`, triggering a
  /// sync. Observers are notified on value changes.
  ///
  /// - Parameters:
  ///   - repository: The `Repository`.
  ///   - map: A block transforming the repository and current value into the
  ///          new wrapped value.
  public init(_ repository: R, map: @escaping (R.DataType, T?) -> T?) {
    self.repository = repository
    self.map = map

    super.init()

    Task {
      switch await repository.getState() {
      case .synced(let data),
          .notSynced(let data):
        value = map(data, value)
      case .initial:
        value = nil
      }

      await repository.addObserver(self)
    }
  }

  /// Creates a `RepositoryLiveData` instance, assigning its value to a mapped
  /// `Repository` value. If unsynced, the initial value is `nil`, and a sync is
  /// triggered. Observers are notified on value changes.
  ///
  /// - Parameters:
  ///   - repository: The `Repository`.
  ///   - map: A block transforming the repository value into the new value.
  public convenience init(_ repository: R, map: @escaping (R.DataType) -> T?) {
    self.init(repository) { value, _ in map(value) }
  }

  /// Creates a `RepositoryLiveData` instance, assigning its value to the
  /// `Repository` value. If unsynced, the value is `nil`, triggering a sync,
  /// and observers will receive the synced value on the next change event.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` providing the wrapped value.
  public convenience init(_ repository: R) where R.DataType == T {
    self.init(repository) { $0 }
  }

  /// Triggers a sync in the `Repository`.
  public func sync() {
    Task {
      try await repository.sync()
    }
  }

  public func repository<U: Repository>(_ repository: U, didSyncWithData data: U.DataType) {
    var newValue: T? = nil

    if let data = data as? R.DataType {
      newValue = map(data, currentValue)
    }

    _log.debug("[RepositoryLiveData<\(T.self)>] Handling sync... OK: \(String(describing: newValue))")

    value = newValue
  }

  public func repository<U: Repository>(_ repository: U, didFailToSyncWithError error: Error) {
    _log.error("[RepositoryLiveData<\(T.self)>] Handling sync... ERR: \(error)")

    value = nil
  }
}
