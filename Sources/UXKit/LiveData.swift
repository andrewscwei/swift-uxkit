// © Sybl

import Foundation

/// A data holder class that can be observed by any object (i.e. the observer), in which the
/// observer will be notified about modifications of the wrapped data. The observer(s) will be
/// notified once upon observing this `LiveData` via `observe(for:listener:)`, and every subsequent
/// time the data is modified until it manually calls `unobserve(for:)`.
public class LiveData<T: Equatable> {

  public typealias Listener = (T) -> Void

  private var listeners: [ObjectIdentifier: Listener] = [:]

  /// The value of the wrapped data.
  public private(set) var value: T {
    didSet {
      guard value != oldValue else { return }

      for (_, listener) in listeners {
        listener(value)
      }
    }
  }

  /// Updates the wrapped data.
  ///
  /// - Parameter value: The new value of the wrapped data.
  public func setValue(_ value: T) {
    self.value = value
  }

  /// Creates a new `LiveData` instance with the specified data to wrap.
  ///
  /// - Parameter value: The value of the wrapped data.
  public init(_ value: T) {
    self.value = value
  }

  /// Begins observing changes to the wrapped data. Note that upon invoking this function, the
  /// `listener` will be notified once immediately. After that, `listener` will be invoked every
  /// time the wrapped data is modified. If the observer is already observing this `LiveData`, the
  /// previous `listener` will be overwritten by this one.
  ///
  /// - Parameters:
  ///   - observer: The object observing this `LiveData`.
  ///   - listener: The block to execute when the wrapped data is modified. It is best to use
  ///               `weak self` within the block.
  public func observe(for observer: AnyObject, listener: @escaping Listener) {
    let identifier = ObjectIdentifier(observer)
    listeners[identifier] = listener
    listener(value)
  }

  /// Stops observing changes to the wrapped data for the specified object (a.k.a. the observer).
  /// Nothing happens if the specified object was never an observer of this `LiveData`.
  ///
  /// - Parameter observer: The object observing this `LiveData`.
  public func unobserve(for observer: AnyObject) {
    let identifier = ObjectIdentifier(observer)
    listeners.removeValue(forKey: identifier)
  }
}
