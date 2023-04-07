// © GHOZT

import BaseKit
import UIKit

class CollectionViewFilterDelegate<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {
  /// Internal `StateMachine` instance.
  lazy var stateMachine = StateMachine(self)

  /// The `UICollectionView` this controller controls.
  private let collectionView: UICollectionView

  /// Internal `UICollectionViewDiffableDataSource` instance.
  private var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> {
    guard let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> else { fatalError("CollectionViewItemSelectionDelegate only works with UICollectionViewDiffableDataSource") }
    return dataSource
  }

  /// Predicate for filtering an item.
  private let filterPredicate: (ItemIdentifier, Any?) -> Bool

  /// Handler invoked when the filtered data set is changed.
  private let filteredDataSetDidChange: () -> Void

  /// Data set of the parent `CollectionViewController`.
  @Stateful var dataSet = [SectionIdentifier: [ItemIdentifier]]()

  /// Filtered data set.
  @Stateful var filteredDataSet = [SectionIdentifier: [ItemIdentifier]]() { didSet { filteredDataSetDidChange() }}

  /// Filter query to apply to the data set.
  @Stateful var query: Any?

  init(
    collectionView: UICollectionView,
    filterPredicate: @escaping (ItemIdentifier, Any?) -> Bool,
    filteredDataSetDidChange: @escaping () -> Void
  ) {
    self.collectionView = collectionView
    self.filterPredicate = filterPredicate
    self.filteredDataSetDidChange = filteredDataSetDidChange
  }

  /// Invalidates the filtered data set, ensuring that it contains only the items
  /// inside `dataSet` of its parent `CollectionViewController`.
  func invalidateFilteredDataSet() {
    var newFilteredDataSet = filteredDataSet

    defer {
      filteredDataSet = newFilteredDataSet
    }

    for (section, _) in newFilteredDataSet {
      if !dataSet.keys.contains(section) {
        newFilteredDataSet.removeValue(forKey: section)
      }
    }

    for (section, items) in dataSet {
      guard let filteredItems = newFilteredDataSet[section] else { continue }
      newFilteredDataSet[section] = filteredItems.filter { filteredItem in items.contains(where: { $0.isEqual(to: filteredItem) }) }
    }
  }

  /// Updates the filtered data set with the specified query.
  ///
  /// - Parameters:
  ///   - query: Query.
  private func updateFilteredDataSet(with query: Any?) {
    filteredDataSet = Dictionary(uniqueKeysWithValues: dataSet.map { section, items in
      (section, items.filter { filterPredicate($0, query) })
    })
  }
}

extension CollectionViewFilterDelegate: StateMachineDelegate {
  func update(check: StateValidator) {
    if check.isDirty(\CollectionViewFilterDelegate.dataSet) {
      invalidateFilteredDataSet()
    }

    if check.isDirty(\CollectionViewFilterDelegate.dataSet, \CollectionViewFilterDelegate.query) {
      updateFilteredDataSet(with: query)
    }
  }
}
