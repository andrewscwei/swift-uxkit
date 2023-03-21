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
//  /// Invalidates current visible cells, subsequently reinitializes (but not
//  /// recreating) them.
//  public func invalidateVislbleCells() {
//    for cell in collectionView.visibleCells {
//      guard let indexPath = collectionView.indexPath(for: cell) else { continue }
//      initCell(cell, at: indexPath)
//    }
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
