import BaseKit
import UIKit

class CollectionViewScrollDelegate<S: Hashable, I: Hashable> {
  /// Internal `StateMachine` instance.
  lazy var stateMachine = StateMachine(self)

  /// The `UICollectionView` this controller controls.
  private let collectionView: UICollectionView

  /// Internal `UICollectionViewDiffableDataSource` instance.
  private var collectionViewDataSource: UICollectionViewDiffableDataSource<S, I> {
    guard let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSource<S, I> else { fatalError("CollectionViewItemSelectionDelegate only works with UICollectionViewDiffableDataSource") }
    return dataSource
  }

  /// Specifies if scrolling is enabled.
  @Stateful var isScrollEnabled: Bool = true

  /// Specifies if scroll indicators are visible.
  @Stateful var showsScrollIndicator: Bool = true

  init(collectionView: UICollectionView) {
    self.collectionView = collectionView
  }

  /// Scrolls to the beginning of the collection.
  ///
  /// - Parameters:
  ///   - animated: Specifies if the scrolling is animated.
  func scrollToBeginning(animated: Bool) {
    collectionView.setContentOffset(collectionView.minContentOffset, animated: animated)
  }

  /// Scrolls to the end of the collection.
  ///
  /// - Parameters:
  ///   - animated: Specifies if the scrolling is animated.
  func scrollToEnd(animated: Bool) {
    collectionView.setContentOffset(collectionView.maxContentOffset, animated: animated)
  }

  /// Scrolls to the item  at the specified index path.
  ///
  /// - Parameters:
  ///   - indexPath: The index path of the cell in the collection view.
  ///   - animated: Specifies if the scrolling is animated.
  func scrollToItem(at indexPath: IndexPath, animated: Bool) {
    if indexPath.section == 0, indexPath.item == 0 {
      collectionView.scrollToItem(at: indexPath, at: [.top, .left], animated: animated)
    }
    else if
      indexPath.section == collectionViewDataSource.snapshot().numberOfSections - 1,
      indexPath.item == collectionViewDataSource.snapshot(for: collectionViewDataSource.snapshot().sectionIdentifiers[indexPath.section]).items.count - 1
    {
      collectionView.scrollToItem(at: indexPath, at: [.bottom, .right], animated: animated)
    }
    else {
      collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: animated)
    }
  }

  /// Scrolls to the cell of the associated item.
  ///
  /// - Parameters:
  ///   - item: Item.
  ///   - animated: Specifies if the scrolling is animated.
  func scrollToItem(_ item: I, animated: Bool) {
    guard
      let section = collectionViewDataSource.snapshot().sectionIdentifier(containingItem: item),
      let sectionIdx = collectionViewDataSource.snapshot().indexOfSection(section),
      let itemIdx = collectionViewDataSource.snapshot(for: section).index(of: item)
    else { return }

    scrollToItem(at: IndexPath(item: itemIdx, section: sectionIdx), animated: animated)
  }
}

extension CollectionViewScrollDelegate: StateMachineDelegate {
  func update(check: StateValidator) {
    if check.isDirty(\CollectionViewScrollDelegate.isScrollEnabled) {
      collectionView.isScrollEnabled = isScrollEnabled
    }

    if check.isDirty(\CollectionViewScrollDelegate.showsScrollIndicator) {
      collectionView.showsVerticalScrollIndicator = showsScrollIndicator
      collectionView.showsHorizontalScrollIndicator = showsScrollIndicator
    }
  }
}
