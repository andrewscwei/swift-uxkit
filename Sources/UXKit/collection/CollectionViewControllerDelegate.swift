// © GHOZT

import UIKit

public protocol CollectionViewControllerDelegate: AnyObject {
  /// Handler invoked to create each cell at the specified index path with
  /// context for the cell's associated section and item identifiers.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///   - indexPath: Index path.
  ///   - section: Section.
  ///   - item: Item.
  ///
  /// - Returns: `UICollectionViewCell` instance.
  func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, cellAtIndexPath indexPath: IndexPath, section: S, item: I) -> UICollectionViewCell?

  /// Handler invoked to create each supplementary view at the specified index
  /// path. `
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewContorller`.
  ///   - indexPath: Index path.
  ///   - kind: String identifier representing the kind of supplementary view.
  ///
  /// - Returns: `UICollectionReusableView` instance or `nil` indicating no
  ///             supplementary views.
  func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, supplementaryViewAtIndexPath indexPath: IndexPath, kind: String) -> UICollectionReusableView?

  /// Handler invoked to create the collection view layout for the internal
  /// collection view.
  ///
  /// - Parameter viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: The `UICollectionViewLayout` instance. If `nil`, the default
  ///            layout will be used.
  func collectionViewControllerCollectionViewLayout<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) -> UICollectionViewLayout?

  /// Handler invoked to determine if an item should be selected.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///   - item: Item.
  ///   - section: Section.
  ///
  /// - Returns: `true` if the item should be selected, `false` otherwise.
  func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldSelectItem item: I, in section: S) -> Bool

  /// Handler invoked to determine if an item should be deselected.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///   - item: Item.
  ///   - section: Section.
  ///
  /// - Returns: `true` if the item should be deselected, `false` otherwise.
  func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldDeselectItem item: I, in section: S) -> Bool

  /// Handler invoked when an item in the collection view is tapped.
  ///
  /// - Parameters:
  ///   - viewCOntroller: The invoking `CollectionViewController`.
  ///   - item: Item.
  ///   - section: Section.
  func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, didTapOnItem item: I, in section: S)

  /// Handler invoked when the item selection has changed.
  ///
  /// - Parameter viewController: The invoking `CollectionViewController`.
  func collectionViewControllerSelectionDidChange<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)

  /// Handler invoked to determine if pulling from either end of the collection
  /// view will trigger a refresh.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: `true` to trigger refresh, `false` otherwise.
  func collectionViewControllerWillPullToRefresh<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) -> Bool

  /// Handler invoked when refresh is triggered after pulling from either end of
  /// the collection view.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  func collectionViewControllerDidPullToRefresh<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)

  /// Handler invoked to create an activity indicator view at the front of the
  /// collection view which will be used for the internal pull-to-refresh
  /// mechanism.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: Some `CollectionViewRefreshControl` instance.
  func collectionViewControllerFrontRefreshControl<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) -> (any CollectionViewRefreshControl)?

  /// Handler invoked to create an activity indicator view at the end of the
  /// collection view which will be used for the internal pull-to-refresh
  /// mechanism.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: Some `CollectionViewRefreshControl` instance.
  func collectionViewControllerEndRefreshControl<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) -> (any CollectionViewRefreshControl)?

  /// Handler invoked to determine if an item should be included in the current
  /// data source snapshot when the specified filter query is applied.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///   - item: Item.
  ///   - query: Filter query.
  ///
  /// - Returns: `true` to include the item, `false` otherwise.
  func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldIncludeItem item: I, withFilterQuery query: Any?) -> Bool

  /// Handler invoked when the collection view scrolls.
  ///
  /// - Parameter viewController: The invoking `CollectionViewController`.
  func collectionViewControllerDidScroll<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)
}

extension CollectionViewControllerDelegate {
  public func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, cellAtIndexPath indexPath: IndexPath, section: S, item: I) -> UICollectionViewCell? { nil }
  public func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, supplementaryViewAtIndexPath indexPath: IndexPath, kind: String) -> UICollectionReusableView? { nil }
  public func collectionViewControllerCollectionViewLayout<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) -> UICollectionViewLayout? { nil }
  public func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldSelectItem item: I, in section: S) -> Bool { true }
  public func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldDeselectItem item: I, in section: S) -> Bool { true }
  public func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, didTapOnItem item: I, in section: S) {}
  public func collectionViewControllerSelectionDidChange<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) {}
  public func collectionViewControllerWillPullToRefresh<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) -> Bool { true }
  public func collectionViewControllerDidPullToRefresh<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) {}
  public func collectionViewControllerFrontRefreshControl<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) -> (any CollectionViewRefreshControl)? { nil }
  public func collectionViewControllerEndRefreshControl<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) -> (any CollectionViewRefreshControl)? { nil }
  public func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldIncludeItem item: I, withFilterQuery query: Any?) -> Bool { true }
  public func collectionViewControllerDidScroll<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)  {}
}
