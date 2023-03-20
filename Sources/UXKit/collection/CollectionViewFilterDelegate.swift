// © GHOZT

import BaseKit
import UIKit

class CollectionViewFilterDelegate<S: Hashable, I: Hashable> {
  /// Internal `StateMachine` instance.
  lazy var stateMachine = StateMachine(self)

  /// The `UICollectionView` this controller controls.
  private let collectionView: UICollectionView

  /// Internal `UICollectionViewDiffableDataSource` instance.
  private var collectionViewDataSource: UICollectionViewDiffableDataSource<S, I> {
    guard let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSource<S, I> else { fatalError("CollectionViewItemSelectionDelegate only works with UICollectionViewDiffableDataSource") }
    return dataSource
  }

  init(collectionView: UICollectionView) {
    self.collectionView = collectionView
  }

  //  /// The dataset with `dataFilter` applied.
  //  private var filteredDataset: [Int: [T]]? = nil
  //
  //  /// Thread-safe getter for `filteredDataset`.
  //  private func getFilteredDataset() -> [Int: [T]]? { lockQueue.sync { filteredDataset } }
  //
  //  /// Thread-safe setter for `filteredDataset`.
  //  ///
  //  /// - Parameters:
  //  ///   - value: The new value.
  //  private func setFilteredDataset(_ value: [Int: [T]]?) {
  //    lockQueue.sync { filteredDataset = value }
  //  }
  //
  //  /// Invalidates the `filteredDataset`, ensuring that it does not contain any
  //  /// outdated data not in the current dataset.
  //  private func invalidateFilteredDataset() {
  //    guard let dataFilter = dataFilter else {
  //      setFilteredDataset(nil)
  //      return
  //    }
  //
  //    let dataset = getDataset()
  //    let newValue = Dictionary(uniqueKeysWithValues: dataset.map { section, data in
  //      (section, data.filter { dataFilterPredicate($0, for: section, filter: dataFilter) })
  //    })
  //
  //    setFilteredDataset(newValue)
  //  }
  //
  //  /// Indicates if the collection currently has a valid data filter applied.
  //  public var hasDataFilter: Bool { dataFilter != nil }
  //
  //  /// Filter to apply to the fetched data. Once set, the collection view will
  //  /// reload with data filtered by this value. How this value translates to data
  //  /// being filtered is up to the method
  //  /// `dataFilterPredicate(datum:for:filter:)`.
  //  public var dataFilter: Any? {
  //    didSet {
  //      invalidateFilteredDataset()
  //      reloadCells(fromBeginning: true)
  //    }
  //  }
  //
  //  /// Predicate method used to iterate over every datum to determine if it
  //  /// should be included whenever the data filter changes. Return `true` to
  //  /// indicate that the datum should be included, `false` otherwise.
  //  ///
  //  /// - Parameters:
  //  ///   - datum: The datum to test for inclusion.
  //  ///   - section: Index of the section this datum belongs to.
  //  ///
  //  /// - Returns: `true` to include this datum, `false` otherwise.
  //  open func dataFilterPredicate(_ datum: T, for section: Int, filter: Any) -> Bool { false }
}

extension CollectionViewFilterDelegate: StateMachineDelegate {
  func update(check: StateValidator) {

  }
}
