/// Specifies how cells are selected in a `UICollectionView`.
public enum CollectionViewSelectionMode {

  /// No selection allowed.
  case none

  /// Can only select one cell at a time.
  case single(togglable: Bool)

  /// Can select multiple cells.
  case multiple
}
