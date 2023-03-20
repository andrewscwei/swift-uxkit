//// © GHOZT
//
//import BaseKit
//import UIKit
//
//open class Foo<T: Equatable>: UICollectionViewController, UICollectionViewDelegateFlowLayout, StateMachineDelegate {
//
//  // MARK: - Updating
//
//  open func update(check: StateValidator) {
//    if check.isDirty(\Foo.orientation, \Foo.cellAlignment, \Foo.separatorStyle, \Foo.contentInsets, \Foo.sectionSeparatorWidth, \Foo.cellSeparatorWidth) {
//
//      flowLayout.orientation = orientation
//      flowLayout.separatorPadding = cellSpacing * 0.5
//      flowLayout.sectionSeparatorWidth = (separatorStyle == .none) || (separatorStyle == .cellsOnly) ? 0.0 : sectionSeparatorWidth
//      flowLayout.cellSeparatorWidth = (separatorStyle == .none) || (separatorStyle == .sectionsOnly) ? 0.0 : cellSeparatorWidth
//
//      switch orientation {
//      case .vertical:
//        collectionView.alwaysBounceHorizontal = false
//        collectionView.alwaysBounceVertical = true
//        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical
//      default:
//        collectionView.alwaysBounceHorizontal = true
//        collectionView.alwaysBounceVertical = false
//        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
//      }
//    }
//
//    if check.isDirty(\Foo.dataState) {
//      switch dataState {
//      case .loading(let prevDataState):
//        isScrollEnabled = prevDataState == .hasData
//      case .hasData:
//        isScrollEnabled = true
//      default:
//        isScrollEnabled = false
//      }
//
//      if let backgroundView = collectionView.backgroundView {
//        let newPlaceholderView = placeholderView(for: dataState)
//        newPlaceholderView?.accessibilityIdentifier = placeholderIdentifier(for: dataState)
//
//        if
//          let newId = newPlaceholderView?.accessibilityIdentifier,
//          let oldId = placeholderView?.accessibilityIdentifier,
//          newId == oldId
//        {
//          // Do nothing because they are the same.
//        }
//        else {
//          placeholderView?.removeFromSuperview()
//          placeholderView = nil
//
//          // Handle transition in animation.
//          if let placeholderView = newPlaceholderView {
//            switch placeholderTransitionStyle {
//            case .fade:
//              placeholderView.alpha = 0.0
//
//              UIView.transition(with: backgroundView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
//                backgroundView.addSubview(placeholderView)
//                placeholderView.alpha = 1.0
//              }, completion: nil)
//            case .slideUp:
//              placeholderView.transform = CGAffineTransform(translationX: 0, y: 20)
//              placeholderView.alpha = 0.0
//
//              UIView.transition(with: backgroundView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
//                backgroundView.addSubview(placeholderView)
//                placeholderView.transform = CGAffineTransform(translationX: 0, y: 0)
//                placeholderView.alpha = 1.0
//              }, completion: nil)
//            case .slideRight:
//              placeholderView.transform = CGAffineTransform(translationX: -20, y: 0)
//              placeholderView.alpha = 0.0
//
//              UIView.transition(with: backgroundView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
//                backgroundView.addSubview(placeholderView)
//                placeholderView.transform = CGAffineTransform(translationX: 0, y: 0)
//                placeholderView.alpha = 1.0
//              }, completion: nil)
//            case .slideDown:
//              placeholderView.transform = CGAffineTransform(translationX: 0, y: -20)
//              placeholderView.alpha = 0.0
//
//              UIView.transition(with: backgroundView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
//                backgroundView.addSubview(placeholderView)
//                placeholderView.transform = CGAffineTransform(translationX: 0, y: 0)
//                placeholderView.alpha = 1.0
//              }, completion: nil)
//            case .slideLeft:
//              placeholderView.transform = CGAffineTransform(translationX: 20, y: 0)
//              placeholderView.alpha = 0.0
//
//              UIView.transition(with: backgroundView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
//                backgroundView.addSubview(placeholderView)
//                placeholderView.transform = CGAffineTransform(translationX: 0, y: 0)
//                placeholderView.alpha = 1.0
//              }, completion: nil)
//            default:
//              backgroundView.addSubview(placeholderView)
//            }
//
//            placeholderView.autoLayout {
//              $0.alignToSuperview()
//            }
//
//            self.placeholderView = placeholderView
//          }
//        }
//      }
//    }
//
//    if check.isDirty(\Foo.sectionSeparatorColor) {
//      if let sectionSeparatorColor = sectionSeparatorColor {
//        flowLayout.sectionSeparatorColor = sectionSeparatorColor
//      }
//    }
//
//    if check.isDirty(\Foo.cellSeparatorColor) {
//      if let cellSeparatorColor = cellSeparatorColor {
//        flowLayout.cellSeparatorColor = cellSeparatorColor
//      }
//    }
//  }
//
//  // MARK: - Data Management
//
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
//
//  /// Gets the data count at the specified section. If a section is not
//  /// provided, the total data count across all sections will be returned.
//  ///
//  /// - Parameters:
//  ///   - section: Optional section index.
//  ///
//  /// - Returns: The count.
//  public func count(for section: Int? = nil, filtered: Bool? = nil) -> Int {
//    if let section = section {
//      return data(for: section, filtered: filtered)?.count ?? 0
//    }
//    else {
//      return Array(0 ..< numberOfSections).reduce(0, { $0 + count(for: $1) })
//    }
//  }
//
//  /// Cancels the reload operation and reverts the data state back to the
//  /// previous state.
//  open func cancelReload() {
//    // Revert to previous state if current state is loading.
//    switch dataState {
//    case .loading(let prevDataState):
//      self.dataState = prevDataState ?? .default
//    default:
//      break
//    }
//  }
//
//  /// Invalidates current visible cells, subsequently reinitializes (but not
//  /// recreating) them.
//  public func invalidateVislbleCells() {
//    for cell in collectionView.visibleCells {
//      guard let indexPath = collectionView.indexPath(for: cell) else { continue }
//      initCell(cell, at: indexPath)
//    }
//  }
//
//  /// Handler invoked when data is reloaded.
//  private func dataDidReload() {
//    delegate?.dataCollectionViewControllerDidReloadData(self)
//  }
//
//  // MARK: - Layout Management
//
//  /// Index path of the nearest visible cell.
//  public var indexPathForNearestVisibleCell: IndexPath? {
//    var out: IndexPath?
//    var delta: CGFloat = .greatestFiniteMagnitude
//
//    switch orientation {
//    case .vertical:
//      let centerY: CGFloat = collectionView.contentOffset.y + collectionView.bounds.size.height * 0.5
//
//      for cell in collectionView.visibleCells{
//        let cellHeight = cell.bounds.height
//        let cellCenterY: CGFloat = cell.frame.minY + cellHeight * 0.5
//        let distance = CGFloat(fabsf(Float(centerY) - Float(cellCenterY)))
//
//        if distance < delta, let indexPath = collectionView.indexPath(for: cell) {
//          delta = distance
//          out = indexPath
//        }
//      }
//    default:
//      let centerX: CGFloat = collectionView.contentOffset.x + collectionView.bounds.size.width * 0.5
//
//      for cell in collectionView.visibleCells {
//        let cellWidth = cell.bounds.width
//        let cellCenterX: CGFloat = cell.frame.minX + cellWidth * 0.5
//        let distance = CGFloat(fabsf(Float(centerX) - Float(cellCenterX)))
//
//        if distance < delta, let indexPath = collectionView.indexPath(for: cell) {
//          delta = distance
//          out = indexPath
//        }
//      }
//    }
//
//    return out
//  }
//
//  /// Reloads the cells in the collection view. Call this method instead of
//  /// `collectionView.reloadData`.
//  ///
//  /// - Parameters:
//  ///   - fromBeginning: Specifies if the collection view should move its scroll
//  ///                    position to the beginning (unanimated) after the cells
//  ///                    are reloaded, defaults to `false`.
//  private func reloadCells(fromBeginning: Bool = false) {
//    // Reload data in collection view.
//    collectionView.reloadData()
//
//    // Scroll to beginning at the next UI cycle (otherwise causes jittering) if
//    // needed.
//    if (fromBeginning) {
//      DispatchQueue.main.async {
//        self.scrollToBeginning(animated: false)
//      }
//    }
//
//    // Restore previously selected data.
//    switch selectionMode {
//    case .single, .multiple:
//      for (section, entries) in getSelectedDataset() {
//        for entry in entries {
//          if let index = firstIndex(for: entry, at: section) {
//            selectCellInCollectionView(at: IndexPath(item: index, section: section))
//          }
//        }
//      }
//    default: break
//    }
//  }
//
//  // MARK: - Scrolling
