// © Sybl

extension DataCollectionViewController {

  /// Specifies how cells are selected in the collection view.
  public enum SelectionMode {
    /// No selection allowed.
    case none

    /// Can only select one cell at a time.
    case single

    /// Can select multiple cells.
    case multiple
  }
}
