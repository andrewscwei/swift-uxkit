// © GHOZT

extension DataCollectionViewController {

  /// Enum describing the state of the data provided to the
  /// `DataCollectionViewController`.
  public enum DataState: Equatable, CustomStringConvertible {
    /// The default idle state.
    case `default`

    /// This state indicates that data loading is in progress.
    indirect case loading(from: DataState?)

    /// Data is loaded successfully and it is not empty.
    case hasData

    /// Data is loaded successfully but it is empty.
    case noData

    /// An error occurred while loading data.
    case error(error: Error?)

    public static func == (lhs: DataState, rhs: DataState) -> Bool {
      switch lhs {
      case .default: if case .default = rhs { return true }
      case .loading(_): if case .loading(_) = rhs { return true }
      case .hasData: if case .hasData = rhs { return true }
      case .noData: if case .noData = rhs { return true }
      case .error(_): if case .error(_) = rhs { return true }
      }
      return false
    }

    public var description: String {
      switch self {
      case .default: return "default"
      case .loading(_): return "loading"
      case .hasData: return "hasData"
      case .noData: return "noData"
      case .error(_): return "error"
      }
    }
  }
}
