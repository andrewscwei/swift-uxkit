// © GHOZT

import Foundation

public protocol CollectionViewControllerDelegate: AnyObject {
  /// Method invoked when the item selection of the collection view has changed.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController` instance.
  func collectionViewControllerSelectionDidChange<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)

  /// Method invoked when scrolling the collection view.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController` instance.
  func collectionViewControllerDidScroll<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)

  /// Handler invoked to determine if an item should be selected by the
  /// `CollectionViewController` instance.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController` instance.
  ///   - item: Item.
  ///   - section: Section.
  ///
  /// - Returns: `true` if item should be selected, `false` otherwise.
  func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldSelectItem item: I, in section: S) -> Bool

  /// Handler invoked to determine if an item should be deselected by the
  /// `CollectionViewController` instance.
  ///
  /// - Parameters:
  ///   - viewController: The invoking `CollectionViewController` instance.
  ///   - item: Item.
  ///   - section: Section.
  ///
  /// - Returns: `true` if item should be deselected, `false` otherwise.
  func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldDeselectItem item: I, in section: S) -> Bool
}

extension CollectionViewControllerDelegate {
  public func collectionViewControllerSelectionDidChange<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) {}
  public func collectionViewControllerDidScroll<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)  {}
  public func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldSelectItem item: I, in section: S) -> Bool { true }
  public func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldDeselectItem item: I, in section: S) -> Bool { true }
}
