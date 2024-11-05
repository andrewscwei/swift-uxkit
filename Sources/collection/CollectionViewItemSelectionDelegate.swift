import UIKit

class CollectionViewItemSelectionDelegate<S: Hashable, I: Hashable> {

  /// Internal `StateMachine` instance.
  lazy var stateMachine = StateMachine(self)

  /// The `UICollectionView` this controller controls.
  private let collectionView: UICollectionView

  /// Internal `UICollectionViewDiffableDataSource` instance.
  private var collectionViewDataSource: UICollectionViewDiffableDataSource<S, I> {
    guard let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSource<S, I> else { fatalError("CollectionViewItemSelectionDelegate only works with UICollectionViewDiffableDataSource") }
    return dataSource
  }

  /// Handler invoked when selected items have changed.
  private let selectionDidChangeHandler: () -> Void

  /// Handler that determines if an item should be selected.
  private let shouldSelectItemHandler: (I, S) -> Bool

  /// Handler that determines if an item should be deselected.
  private let shouldDeselectItemHandler: (I, S) -> Bool

  /// Data set of the parent `CollectionViewController`.
  @Stateful var dataSet = [S: [I]]()

  /// Internal stored value of the currently selected items.
  @Stateful private var selectedItems = [I]() { didSet { if selectedItems != oldValue { selectionDidChangeHandler() } } }

  /// Specifies how cells are selected in the collection view.
  @Stateful var selectionMode: CollectionViewSelectionMode = .none

  init(
    collectionView: UICollectionView,
    selectionDidChange: @escaping () -> Void,
    shouldSelectItem: @escaping (I, S) -> Bool,
    shouldDeselectItem: @escaping (I, S) -> Bool
  ) {
    self.collectionView = collectionView
    self.selectionDidChangeHandler = selectionDidChange
    self.shouldSelectItemHandler = shouldSelectItem
    self.shouldDeselectItemHandler = shouldDeselectItem
  }

  /// Returns the sections of the currently selected items.
  ///
  /// - Returns: The sections of the currently selected items.
  func getSelectedSections() -> [S] { Array(Set(getSelectedItems().compactMap { collectionViewDataSource.snapshot().sectionIdentifier(containingItem: $0) })) }

  /// Returns the current value of selected items stored in this controller.
  ///
  /// - Returns: The current value of the selected items.
  func getSelectedItems() -> [I] { selectedItems }

  /// Sets the value of selected items stored in this controller.
  ///
  /// - Parameter items: Items to set the value of selected items to.
  func setSelectedItems(_ items: [I]) {
    if case .none = selectionMode { return }
    selectedItems = items
  }

  /// Returns the index paths of the selected items.
  ///
  /// - Returns: The selected index paths.
  func getIndexPathsForSelectedItems() -> [IndexPath] { collectionView.indexPathsForSelectedItems ?? [] }

  /// Indicates if an item at the specified index path is selected in this
  /// controller.
  ///
  /// - Parameters:
  ///   - indexPath: Index path.
  ///
  /// - Returns: `true` if selected, `false` otherwise.
  func isItemSelected(at indexPath: IndexPath) -> Bool { getIndexPathsForSelectedItems().contains(indexPath) }

  /// Indicates if an item is selected in this controller.
  ///
  /// - Parameters:
  ///   - item: Item.
  ///   - predicate: Custom method for checking the equality between two items.
  ///
  /// - Returns: `true` if selected, `false` otherwise.
  func isItemSelected(_ item: I, where predicate: (I, I) -> Bool) -> Bool { getSelectedItems().contains(where: { predicate($0, item) }) }

  /// Indicates if all items are selected in a particular section.
  ///
  /// - Parameters:
  ///   - section: Section.
  ///   - predicate: Custom method for checking the equality between two items.
  /// - Returns: `true` if all are selected, `false` otherwise.
  func areAllItemsSelected(in section: S, where predicate: (I, I) -> Bool) -> Bool {
    let items = collectionViewDataSource.snapshot(for: section).items

    for item in items {
      if !isItemSelected(item, where: predicate) { return false }
    }

    return true
  }

  /// Indicates if all items are deselected in a particular section.
  ///
  /// - Parameters:
  ///   - section: Section.
  ///   - predicate: Custom method for checking the equality between two items.
  /// - Returns: `true` if all are deselected, `false` otherwise.
  func areAllItemsDeselected(in section: S, where predicate: (I, I) -> Bool) -> Bool {
    let items = collectionViewDataSource.snapshot(for: section).items

    for item in items {
      if isItemSelected(item, where: predicate) { return false }
    }

    return true
  }

  /// Selects an item currently in the collection view,  at the specified index
  /// path.
  ///
  /// - Parameters:
  ///   - indexPath: Index path.
  ///   - predicate: Method that determines the equality of two items.
  /// - Returns: The selected item, if any.
  @discardableResult
  func selectItem(at indexPath: IndexPath, where predicate: (I, I) -> Bool) -> I? {
    guard let item = mapIndexPathToItem(indexPath) else { return nil }

    return selectItem(item, where: predicate)
  }

  /// Selects an item currently in the collection view.
  ///
  /// - Parameters:
  ///   - item: Item.
  ///   - predicate: Method that determines the equality of two items.
  /// - Returns: The selected item if any.
  @discardableResult
  func selectItem(_ item: I, where predicate: (I, I) -> Bool) -> I? {
    guard let section = collectionViewDataSource.snapshot().sectionIdentifier(containingItem: item), shouldSelectItem(item, in: section) else { return nil }

    return addSelectedItem(item, where: predicate)
  }

  /// Selects all items currently in the collection view, in the specified
  /// section.
  ///
  /// - Parameters:
  ///   - section: Section.
  ///   - predicate: Method that determines the equality of two items.
  /// - Returns: The selected items.
  @discardableResult
  func selectAllItems(in section: S, where predicate: (I, I) -> Bool) -> [I] {
    guard case .multiple = selectionMode else { return [] }

    stateMachine.beginTransaction()

    defer {
      stateMachine.commit()
    }

    var selectedItems = [I]()

    for item in collectionViewDataSource.snapshot(for: section).items {
      guard shouldSelectItem(item, in: section) else { continue }
      guard let item = addSelectedItem(item, where: predicate) else { continue }
      selectedItems.append(item)
    }

    return selectedItems
  }

  /// Deselects an item currently in the collection view,  at the specified
  /// index path.
  ///
  /// - Parameters:
  ///   - indexPath: Index path.
  ///   - predicate: Method that determines the equality of two items.
  /// - Returns: The deselected item, if any.
  @discardableResult
  func deselectItem(at indexPath: IndexPath, where predicate: (I, I) -> Bool) -> I? {
    guard let item = mapIndexPathToItem(indexPath) else { return nil }

    return deselectItem(item, where: predicate)
  }

  /// Deselects an item currently in the collection view.
  ///
  /// - Parameters:
  ///   - item: Item.
  ///   - predicate: Method that determines the equality of two items.
  /// - Returns: The deselected item if any.
  @discardableResult
  func deselectItem(_ item: I, where predicate: (I, I) -> Bool) -> I? {
    guard let section = collectionViewDataSource.snapshot().sectionIdentifier(containingItem: item), shouldDeselectItem(item, in: section) else { return nil }

    return removeSelectedItem(item, where: predicate)
  }

  /// Deselects all items currently in the collection view, in the specified
  /// section.
  ///
  /// - Parameters:
  ///   - section: Section.
  ///   - predicate: Method that determines the equality of two items.
  /// - Returns: The deselected items.
  @discardableResult
  func deselectAllItems(in section: S, where predicate: (I, I) -> Bool) -> [I] {
    if case .none = selectionMode { return [] }

    stateMachine.beginTransaction()

    defer {
      stateMachine.commit()
    }

    var deselectedItems = [I]()

    for item in collectionViewDataSource.snapshot(for: section).items {
      guard shouldDeselectItem(item, in: section) else  { continue }
      guard let item = removeSelectedItem(item, where: predicate) else { continue }
      deselectedItems.append(item)
    }

    return deselectedItems
  }

  /// Indicates if an item should be selected.
  ///
  /// - Parameters:
  ///   - item: Item.
  ///   - section: Section of item.
  /// - Returns: `true` indicates item should be selected, `false` otherwise.
  func shouldSelectItem(_ item: I, in section: S) -> Bool {
    let flag = shouldSelectItemHandler(item, section)

    switch selectionMode {
    case .single, .multiple:
      return true && flag
    case .none:
      return false && flag
    }
  }

  /// Indicates if an item at the specified index path should be selected.
  ///
  /// - Parameter indexPath: Index path.
  /// - Returns: `true` indicates item should be selected, `false` otherwise.
  func shouldSelectItem(at indexPath: IndexPath) -> Bool {
    guard let item = mapIndexPathToItem(indexPath), let section = collectionViewDataSource.snapshot().sectionIdentifier(containingItem: item) else { return false }

    return shouldSelectItem(item, in: section)
  }

  /// Indicates if an item should be deselected, used in tandem with delegate
  /// method `collectionViewItemSelectionController(_:shouldDeselectItem:in:)`.
  ///
  /// - Parameters:
  ///   - item: Item.
  ///   - section: Section of item.
  /// - Returns: `true` indicates item should be deselected, `false` otherwise.
  func shouldDeselectItem(_ item: I, in section: S) -> Bool {
    let flag = shouldDeselectItemHandler(item, section)

    switch selectionMode {
    case .single(let togglable):
      return togglable && flag
    case .multiple:
      return true && flag
    case .none:
      return false && flag
    }
  }

  /// Indicates if an item at the specified index path should be deselected.
  ///
  /// - Parameter indexPath: Index path.
  /// - Returns: `true` indicates item should be deselected, `false` otherwise.
  func shouldDeselectItem(at indexPath: IndexPath) -> Bool {
    guard let item = mapIndexPathToItem(indexPath), let section = collectionViewDataSource.snapshot().sectionIdentifier(containingItem: item) else { return false }

    return shouldDeselectItem(item, in: section)
  }

  /// Invalidates the selected items, ensuring that it contains only the items
  /// inside `dataSet` of its parent `CollectionViewController`.
  func invalidateSelectedItems() {
    let items = dataSet.reduce([]) { $0 + $1.value }
    selectedItems = selectedItems.filter({ item in items.contains(where: { $0 == item }) })
  }

  /// Invalidates the index paths of selected items in the collection view,
  /// ensuring that it is in sync with `selectedItems` which is the source of
  /// truth for which items are selected.
  func invalidateSelectedIndexPaths() {
    let isAnimated = false
    let oldSelectedIndexPaths = getIndexPathsForSelectedItems()
    let newSelectedIndexPaths = selectedItems.compactMap { mapItemToIndexPath($0) }
    let indexPathsToSelect = Set(newSelectedIndexPaths).subtracting(Set(oldSelectedIndexPaths))
    let indexPathsToDeselect = Set(oldSelectedIndexPaths).subtracting(Set(newSelectedIndexPaths))

    indexPathsToSelect.forEach { collectionView.selectItem(at: $0, animated: isAnimated, scrollPosition: .init(rawValue: 0)) }
    indexPathsToDeselect.forEach { collectionView.deselectItem(at: $0, animated: isAnimated) }
  }

  @discardableResult
  private func addSelectedItem(_ item: I, where predicate: (I, I) -> Bool) -> I? {
    guard collectionViewDataSource.snapshot().indexOfItem(item) != nil else { return nil }

    var newSet = selectedItems

    defer {
      selectedItems = newSet
    }

    guard !newSet.contains(where: { predicate($0, item) }) else { return nil }

    switch selectionMode {
    case .single:
      newSet = [item]
    case .multiple:
      newSet += [item]
    default: break
    }

    return item
  }

  @discardableResult
  private func removeSelectedItem(_ item: I, where predicate: (I, I) -> Bool) -> I? {
    guard collectionViewDataSource.snapshot().indexOfItem(item) != nil else { return nil }

    var newSet = selectedItems

    defer {
      selectedItems = newSet
    }

    switch selectionMode {
    case .single:
      guard newSet.count > 0 else { return nil }
      newSet = []
    case .multiple:
      guard newSet.contains(where: { predicate($0, item) }) else { return nil }
      newSet = newSet.filter { !predicate($0, item) }
    default: break
    }

    return item
  }

  func mapIndexPathToItem(_ indexPath: IndexPath) -> I? {
    let section = collectionViewDataSource.snapshot().sectionIdentifiers[indexPath.section]
    let items = collectionViewDataSource.snapshot(for: section).items

    return items[indexPath.item]
  }

  func mapItemToIndexPath(_ item: I) -> IndexPath? {
    guard
      let section = collectionViewDataSource.snapshot().sectionIdentifier(containingItem: item),
      let sectionIdx = collectionViewDataSource.snapshot().indexOfSection(section),
      let itemIdx = collectionViewDataSource.snapshot(for: section).index(of: item)
    else { return nil }

    return IndexPath(item: itemIdx, section: sectionIdx)
  }

  private func areOrderedItemsEqual(p0: [I], p1: [I], where predicate: (I, I) -> Bool) -> Bool {
    guard p0.count == p1.count else { return false }

    for (index, item) in p0.enumerated() {
      guard item == p1[index] else { return false }
    }

    return true
  }
}

extension CollectionViewItemSelectionDelegate: StateMachineDelegate {
  func update(check: StateValidator) {
    if check.isDirty(\CollectionViewItemSelectionDelegate.selectionMode) {
      switch selectionMode {
      case .multiple:
        collectionView.allowsMultipleSelection = true
        collectionView.allowsSelection = true
      case .single:
        // This is enabled for a reason. The native `UICollectionView` behaves
        // weirdly, such that if `allowsMultipleSelection` is `false`, and a
        // cell has `collectionView:shouldSelectItemAt:` returning `false`, the
        // previously selected cell still gets deselected even though no new
        // cell is being selected. Hence this custom controller manually handles
        // single selection behavior.
        collectionView.allowsMultipleSelection = true
        collectionView.allowsSelection = true
      default:
        collectionView.allowsMultipleSelection = false
        // This is enabled even though the intended selection behavior is none
        // so that the collection view will still invoke
        // `collectionView(_:shouldSelectItemAt:)`, which is useful for
        // capturing tap gesture for free. This controller still discard the
        // selection automatically to satisfy the intended selection mode.
        collectionView.allowsSelection = true
      }
    }

    if check.isDirty(\CollectionViewItemSelectionDelegate.dataSet) {
      invalidateSelectedItems()
    }

    if check.isDirty(\CollectionViewItemSelectionDelegate.dataSet, \CollectionViewItemSelectionDelegate.selectedItems) {
      invalidateSelectedIndexPaths()
    }
  }
}
