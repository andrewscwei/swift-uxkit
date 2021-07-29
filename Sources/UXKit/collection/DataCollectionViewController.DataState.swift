// © Sybl

extension DataCollectionViewController {

  /// State indicating the various stages of dataset processing.
  public enum DataState: Equatable {
    /// Default idle state.
    case `default`

    /// Data are in the middle of loading.
    indirect case loading(from: DataState?)

    /// Data is fetched successfully and the collection view is populated with data.
    case hasData

    /// Data is fetched successfully but it is empty and there is nothing to populate in the collection view.
    case noData

    /// Error occurred while fetching data.
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

    public func toString() -> String {
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
