// © GHOZT

import Foundation

public protocol CollectionViewControllerDelegate: AnyObject {
  func collectionViewControllerSelectionDidChange<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)
  func collectionViewControllerDidScroll<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)
  func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldSelectItem item: I, in section: S) -> Bool
  func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldDeselectItem item: I, in section: S) -> Bool
  func collectionViewControllerWillPullToReload<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) -> Bool
  func collectionViewControllerDidPullToReload<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)
}

extension CollectionViewControllerDelegate {
  public func collectionViewControllerSelectionDidChange<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) {}
  public func collectionViewControllerDidScroll<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>)  {}
  public func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldSelectItem item: I, in section: S) -> Bool { true }
  public func collectionViewController<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>, shouldDeselectItem item: I, in section: S) -> Bool { true }
  public func collectionViewControllerWillPullToReload<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) -> Bool { false }
  public func collectionViewControllerDidPullToReload<S: CaseIterable & Hashable, I: Hashable>(_ viewController: CollectionViewController<S, I>) {}
}
