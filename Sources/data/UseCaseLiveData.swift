import BaseKit
import Foundation

/// A `LiveData` type that holds the transformed `T` value from a `UseCase`
/// output.
public class UseCaseLiveData<T: Equatable, U: UseCase>: LiveData<T> {
  private let transform: (U.Output) -> T

  let useCase: U

  /// Creates a new `UseCaseLiveData` instance.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase`.
  ///   - transform: A block that transforms the use case output to the wrapped
  ///                value.
  public init(_ useCase: U, transform: @escaping (U.Output) -> T) {
    self.useCase = useCase
    self.transform = transform

    super.init()
  }

  /// Creates a new `UseCaseLiveData` instance.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase`.
  public convenience init(_ useCase: U) where U.Output == T {
    self.init(useCase) { $0 }
  }

  /// Interacts with the use case with the specified input. Upon success, the
  /// output will be stored in the wrapped value. If a failure occurred, the
  /// wrapped value will be set to `nil`.
  ///
  /// - Parameters:
  ///   - params: Input for the use case.
  public func interact(params: U.Input) {
    Task {
      do {
        let result = try await self.useCase.run(params: params)

        self.value = self.transform(result)
      }
      catch {
        self.value = nil
      }
    }
  }

  /// Interacts with the use case with the specified input. Upon success, the
  /// output will be stored in the wrapped value. If a failure occurred, the
  /// wrapped value will be set to `nil`.
  public func interact() where U.Input == Void {
    Task {
      do {
        let result = try await self.useCase.run(params: ())

        self.value = self.transform(result)
      }
      catch {
        self.value = nil
      }
    }
  }
}
