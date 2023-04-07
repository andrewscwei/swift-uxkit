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
  func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, cellAtIndexPath indexPath: IndexPath, section: SectionIdentifier, item: ItemIdentifier) -> UICollectionViewCell?

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
  func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, supplementaryViewAtIndexPath indexPath: IndexPath, kind: String) -> UICollectionReusableView?

  /// Handler invoked to create the collection view layout for the internal
  /// collection view.
  ///
  /// - Parameter viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: The `UICollectionViewLayout` instance. If `nil`, the default
  ///            layout will be used.
  func collectionViewControllerCollectionViewLayout<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> UICollectionViewLayout?

  /// Handler invoked to determine if an item should be selected.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///   - item: Item.
  ///   - section: Section.
  ///
  /// - Returns: `true` if the item should be selected, `false` otherwise.
  func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, shouldSelectItem item: ItemIdentifier, in section: SectionIdentifier) -> Bool

  /// Handler invoked to determine if an item should be deselected.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///   - item: Item.
  ///   - section: Section.
  ///
  /// - Returns: `true` if the item should be deselected, `false` otherwise.
  func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, shouldDeselectItem item: ItemIdentifier, in section: SectionIdentifier) -> Bool

  /// Handler invoked when an item in the collection view is tapped.
  ///
  /// - Parameters:
  ///   - viewCOntroller: The invoking `CollectionViewController`.
  ///   - item: Item.
  ///   - section: Section.
  func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, didTapOnItem item: ItemIdentifier, in section: SectionIdentifier)

  /// Handler invoked when the item selection has changed.
  ///
  /// - Parameter viewController: The invoking `CollectionViewController`.
  func collectionViewControllerSelectionDidChange<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>)

  /// Handler invoked to determine if pulling from either end of the collection
  /// view will trigger a refresh.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: `true` to trigger refresh, `false` otherwise.
  func collectionViewControllerWillPullToRefresh<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> Bool

  /// Handler invoked when refresh is triggered after pulling from either end of
  /// the collection view.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  func collectionViewControllerDidPullToRefresh<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>)

  /// Handler invoked to create an activity indicator view at the front of the
  /// collection view which will be used for the internal pull-to-refresh
  /// mechanism.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: Some `CollectionViewRefreshControl` instance.
  func collectionViewControllerFrontRefreshControl<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> (any CollectionViewRefreshControl)?

  /// Handler invoked to create an activity indicator view at the end of the
  /// collection view which will be used for the internal pull-to-refresh
  /// mechanism.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: Some `CollectionViewRefreshControl` instance.
  func collectionViewControllerEndRefreshControl<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> (any CollectionViewRefreshControl)?

  /// Handler invoked to determine if an item should be included in the current
  /// data source snapshot when the specified filter query is applied.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///   - item: Item.
  ///   - query: Filter query.
  ///
  /// - Returns: `true` to include the item, `false` otherwise.
  func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, shouldIncludeItem item: ItemIdentifier, withFilterQuery query: Any?) -> Bool

  /// Handler invoked when the collection view scrolls.
  ///
  /// - Parameter viewController: The invoking `CollectionViewController`.
  func collectionViewControllerDidScroll<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>)
}

extension CollectionViewControllerDelegate {
  public func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, cellAtIndexPath indexPath: IndexPath, section: SectionIdentifier, item: ItemIdentifier) -> UICollectionViewCell? { nil }
  public func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, supplementaryViewAtIndexPath indexPath: IndexPath, kind: String) -> UICollectionReusableView? { nil }
  public func collectionViewControllerCollectionViewLayout<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> UICollectionViewLayout? { nil }
  public func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, shouldSelectItem item: ItemIdentifier, in section: SectionIdentifier) -> Bool { true }
  public func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, shouldDeselectItem item: ItemIdentifier, in section: SectionIdentifier) -> Bool { true }
  public func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, didTapOnItem item: ItemIdentifier, in section: SectionIdentifier) {}
  public func collectionViewControllerSelectionDidChange<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) {}
  public func collectionViewControllerWillPullToRefresh<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> Bool { true }
  public func collectionViewControllerDidPullToRefresh<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) {}
  public func collectionViewControllerFrontRefreshControl<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> (any CollectionViewRefreshControl)? { nil }
  public func collectionViewControllerEndRefreshControl<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> (any CollectionViewRefreshControl)? { nil }
  public func collectionViewController<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, shouldIncludeItem item: ItemIdentifier, withFilterQuery query: Any?) -> Bool { true }
  public func collectionViewControllerDidScroll<SectionIdentifier: CaseIterable & Hashable, ItemIdentifier: Hashable>(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>)  {}
}
