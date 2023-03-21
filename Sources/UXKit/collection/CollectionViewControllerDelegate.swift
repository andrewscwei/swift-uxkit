// © GHOZT

import UIKit

public protocol CollectionViewControllerDelegate<SectionIdentifier, ItemIdentifier>: AnyObject {
  associatedtype SectionIdentifier: CaseIterable & Hashable
  associatedtype ItemIdentifier: Hashable

  /// Handler invoked when the item selection has changed.
  ///
  /// - Parameter viewController: The invoking `CollectionViewController`.
  func collectionViewControllerSelectionDidChange(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>)

  /// Handler invoked when the collection view scrolls.
  ///
  /// - Parameter viewController: The invoking `CollectionViewController`.
  func collectionViewControllerDidScroll(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>)

  /// Handler invoked to determine if an item should be selected.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///   - item: Item.
  ///   - section: Section.
  ///
  /// - Returns: `true` if the item should be selected, `false` otherwise.
  func collectionViewController(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, shouldSelectItem item: ItemIdentifier, in section: SectionIdentifier) -> Bool

  /// Handler invoked to determine if an item should be deselected.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///   - item: Item.
  ///   - section: Section.
  ///
  /// - Returns: `true` if the item should be deselected, `false` otherwise.
  func collectionViewController(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, shouldDeselectItem item: ItemIdentifier, in section: SectionIdentifier) -> Bool

  /// Handler invoked to determine if pulling from either end of the collection
  /// view will trigger a reload.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: `true` to trigger reload, `false` otherwise.
  func collectionViewControllerWillPullToReload(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> Bool

  /// Handler invoked when reload is triggered after pulling from either end of
  /// the collection view.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  func collectionViewControllerDidPullToReload(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>)

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
  func collectionViewController(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, cellAtIndexPath indexPath: IndexPath, section: SectionIdentifier, item: ItemIdentifier) -> UICollectionViewCell

  /// Handler invoked to create an activity indicator view at the front of the
  /// collection view which will be used for the internal pull-to-reload
  /// mechanism.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: Some `CollectionViewSpinner` instance.
  func collectionViewControllerFrontSpinner(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> (any CollectionViewSpinner)?

  /// Handler invoked to create an activity indicator view at the end of the
  /// collection view which will be used for the internal pull-to-reload
  /// mechanism.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController`.
  ///
  /// - Returns: Some `CollectionViewSpinner` instance.
  func collectionViewControllerEndSpinner(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> (any CollectionViewSpinner)?
}

extension CollectionViewControllerDelegate {
  public func collectionViewControllerSelectionDidChange(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) {}
  public func collectionViewControllerDidScroll(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>)  {}
  public func collectionViewController(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, shouldSelectItem item: ItemIdentifier, in section: SectionIdentifier) -> Bool { true }
  public func collectionViewController(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>, shouldDeselectItem item: ItemIdentifier, in section: SectionIdentifier) -> Bool { true }
  public func collectionViewControllerWillPullToReload(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> Bool { false }
  public func collectionViewControllerDidPullToReload(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) {}
  public func collectionViewControllerFrontSpinner(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> (any CollectionViewSpinner)? { nil }
  public func collectionViewControllerEndSpinner(_ viewController: CollectionViewController<SectionIdentifier, ItemIdentifier>) -> (any CollectionViewSpinner)? { nil }
}
