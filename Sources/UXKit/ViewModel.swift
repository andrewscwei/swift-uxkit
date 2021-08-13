// © Sybl

import BaseKit

/// A view model for use by a `UIViewController`, facilitating the MVVM pattern.
open class ViewModel {

  public init() {

  }

  /// Interacts with a `UseCase` with an input type `T`.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase` to interact.
  ///   - params: The input parameters of the `UseCase`.
  ///   - completionHandler: Handler invoked upon completion, with the `Result` wrapping the output
  ///                        of the `UseCase` as its success value.
  public func interact<T: UseCase>(_ useCase: T, params: T.Input, completionHandler: @escaping (Result<T.Output, Error>) -> Void = { _ in }) {
    useCase.interact(params: params, completionHandler: completionHandler)
  }

  /// Interacts with a `UseCase` with no input type.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase` to interact.
  ///   - completionHandler: Handler invoked upon completion, with the `Result` wrapping the output
  ///                        of the `UseCase` as its success value.
  public func interact<T: UseCase>(_ useCase: T, completionHandler: @escaping (Result<T.Output, Error>) -> Void = { _ in }) where T.Input == Void {
    useCase.interact(params: (), completionHandler: completionHandler)
  }
}
