// © GHOZT

extension DataCollectionViewController {

  /// Specifies how cells are selected in the `DataCollectionViewController`.
  public enum SelectionMode {
    /// No selection allowed.
    case none

    /// Can only select one cell at a time.
    case single

    /// Can select multiple cells.
    case multiple
  }
}
