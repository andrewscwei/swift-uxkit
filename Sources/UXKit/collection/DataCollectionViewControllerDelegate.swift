// © Sybl

import UIKit

/// Delegate protocol for handling `DataCollectionViewController` events.
public protocol DataCollectionViewControllerDelegate: AnyObject {

  /// Method invoked before data is reloaded.
  ///
  /// - Parameters:
  ///   - collectionViewController: The `DataCollectionViewController` instance that invoked this
  ///                               method.
  ///   - sender: The object that triggered the reload.
  func dataCollectionViewControllerWillReloadData(_ collectionViewController: UICollectionViewController, sender: Any?)

  /// Method invoked after data is reloaded.
  ///
  /// - Parameters:
  ///   - collectionViewController: The `DataCollectionViewController` instance that invoked this
  ///                               method.
  ///   - sender: The object that triggered the reload.
  func dataCollectionViewControllerDidReloadData(_ collectionViewController: UICollectionViewController, sender: Any?)

  /// Method invoked when the data state is changed.
  ///
  /// - Parameters:
  ///   - collectionViewController: The `DataCollectionViewController` instance that invoked this
  ///                               method.
  func dataCollectionViewControllerDataStateDidChange(_ collectionViewController: UICollectionViewController)

  /// Method invoked when the item selection of the collection view has changed.
  ///
  /// - Parameters:
  ///   - collectionViewController: The `DataCollectionViewController` instance that invoked this
  ///                               method.
  func dataCollectionViewControllerSelectionDidChange(_ collectionViewController: UICollectionViewController)

  /// Method invoked when an item is tapped, regardless of the selection mode.
  ///
  /// - Parameters:
  ///   - collectionViewController: The `DataCollectionViewController` instance that invoked this
  ///                               method.
  ///   - indexPath: The index path of the tapped item.
  func dataCollectionViewController(_ collectionViewController: UICollectionViewController, didTapOnCellAt indexPath: IndexPath)

  /// Method invoked when scrolling the collection view.
  ///
  /// - Parameter:
  ///   - collectionViewController: The `DataCollectionViewController` instance that invoked this
  ///                               method.
  func dataCollectionViewControllerDidScroll(_ collectionViewController: UICollectionViewController)

  /// Method invoked when applying default item selection. Return the datum (singular) or data
  /// (plural) to be selected by default. This selection is applied whenever the collection
  /// refreshes and only if there are no preexisting selections at the time of refresh.
  ///
  /// - Parameters:
  ///   - collectionViewController: The `DataCollectionViewController` instance that invoked this
  ///                               method.
  /// - Returns: The datum/data to be selected by default.
  func dataCollectionViewControllerWillApplyDefaultSelection(_ collectionViewController: UICollectionViewController) -> Any?

  /// Method invoked after default item selection is applied.
  ///
  /// - Parameters:
  ///   - collectionViewController: The `DataCollectionViewController` instance that invoked this
  ///                               method.
  func dataCollectionViewControllerDidApplyDefaultSelection(_ collectionViewController: UICollectionViewController)

  /// Method invoked after a cell is initialized.
  ///
  /// - Parameters:
  ///   - collectionViewController: The `DataCollectionViewController` instance that invoked th is
  ///                               method.
  ///   - cell: The cell that was initialized.
  ///   - indexPath: The index path of the cell that was initialized.
  ///
  /// - Returns: The initialized cell.
  func dataCollectionViewController(_ collectionViewController: UICollectionViewController, didInitCell cell: UICollectionViewCell, at indexPath: IndexPath) -> UICollectionViewCell
}

extension DataCollectionViewControllerDelegate {

  public func dataCollectionViewControllerWillReloadData(_ collectionViewController: UICollectionViewController, sender: Any?) {}

  public func dataCollectionViewControllerDidReloadData(_ collectionViewController: UICollectionViewController, sender: Any?) {}

  public func dataCollectionViewControllerDataStateDidChange(_ collectionViewController: UICollectionViewController) {}

  public func dataCollectionViewControllerSelectionDidChange(_ collectionViewController: UICollectionViewController) {}

  public func dataCollectionViewController(_ collectionViewController: UICollectionViewController, didTapOnCellAt indexPath: IndexPath) {}

  public func dataCollectionViewControllerDidScroll(_ collectionViewController: UICollectionViewController) {}

  public func dataCollectionViewControllerWillApplyDefaultSelection(_ collectionViewController: UICollectionViewController) -> Any? { return nil }

  public func dataCollectionViewControllerDidApplyDefaultSelection(_ collectionViewController: UICollectionViewController) {}

  public func dataCollectionViewController(_ collectionViewController: UICollectionViewController, didInitCell cell: UICollectionViewCell, at indexPath: IndexPath) -> UICollectionViewCell {
    return cell
  }
}
