// © Sybl

import BaseKit
import UIKit

/// An abstract `UICollectionViewController` whose backing `UICollectionView` displays a collection
/// of cells based on the provided dataset, each cell representing a *datum* (a singular entry of
/// each individual data in the dataset) of uniform type `T`. The dataset is partitioned into
/// *sections*, each corresponding to a displayable section in the `UICollectionView`.
///
/// `DataCollectionViewController` has native support for the following features:
///   - data filtering (see `dataFilter`)
///   - single/multiple cell selection (see `selectionMode`), persisted across reloads
///   - customizable placeholder view per data state (see `placeholderView(for:)` and
///     `placeholderIdentifier(for:)`)
///   - default selection handled by `DataCollectionViewControllerDelegate` (see
///     `dataCollectionViewControllerWillApplyDefaultSelection(_:)`)
///   - customizable pull-to-refresh triggers and indicators from both ends of the collection (see
///     `frontSpinner`, `endSpinner`, and `collectionViewWillPullToRefreshInDataState(_:)`)
///   - section/cell separators
open class DataCollectionViewController<T: Equatable>: UICollectionViewController, UICollectionViewDelegateFlowLayout, StateMachineDelegate {

  // MARK: - Delegation

  /// Weak reference to this `DataCollectionViewController`'s delegate object.
  public weak var delegate: DataCollectionViewControllerDelegate?

  public lazy var stateMachine: StateMachine = StateMachine(self)

  // MARK: - Life Cycle

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    buildSubviews()
  }

  public init() {
    super.init(collectionViewLayout: flowLayout)
  }

  override init(collectionViewLayout layout: UICollectionViewLayout) {
    fatalError("Restricted use of this initializer because DataCollectionViewController uses a custom UICollectionViewLayout")
  }

  func buildSubviews() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    // Set default properties.
    collectionView.delegate = self
    collectionView.bounces = true
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.backgroundColor = .clear
    collectionView.backgroundView = UIView()
    collectionView.autoLayout { $0.alignToSuperview() }
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    stateMachine.start()

    if shouldRefreshOnLoad {
      // TODO: Remove sender
      refresh(sender: self)
    }
  }

  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    stateMachine.stop()
  }

  /// Refreshes the data, consequently repopulating the collection view.
  ///
  /// - Parameters:
  ///   - sender: The object that triggered the refresh.
  open func refresh(sender: Any? = nil) {
    let group = DispatchGroup()

    group.enter()
    group.enter()

    stopFrontSpinner() { group.leave() }
    stopEndSpinner() { group.leave() }

    group.notify(queue: DispatchQueue.main) {
      self.reloadData(isFiltering: self.hasDataFilter, sender: sender)
    }
  }

  // MARK: - Updating

  open func update(check: StateValidator) {
    if check.isDirty(.layout) {
      collectionView.contentInset = contentInsets

      flowLayout.orientation = orientation
      flowLayout.separatorPadding = cellSpacing * 0.5
      flowLayout.sectionSeparatorWidth = (separatorStyle == .none) || (separatorStyle == .cellsOnly) ? 0.0 : sectionSeparatorWidth
      flowLayout.cellSeparatorWidth = (separatorStyle == .none) || (separatorStyle == .sectionsOnly) ? 0.0 : cellSeparatorWidth

      switch orientation {
      case .vertical:
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical

        if let frontSpinner = frontSpinner {
          if let constraintX = frontSpinnerConstraintX { frontSpinner.removeConstraint(constraintX) }
          if let constraintY = frontSpinnerConstraintY { frontSpinner.removeConstraint(constraintY) }

          frontSpinner.autoLayout {
            self.frontSpinnerConstraintX = $0.alignToSuperview(.centerX).first
            self.frontSpinnerConstraintY = $0.align(.centerY, to: frontSpinner.superview!, for: .top, offset: displacementToTriggerRefresh * 0.5).first
          }
        }

        if let endSpinner = endSpinner {
          if let constraintX = endSpinnerConstraintX { endSpinner.removeConstraint(constraintX) }
          if let constraintY = endSpinnerConstraintY { endSpinner.removeConstraint(constraintY) }

          endSpinner.autoLayout {
            self.endSpinnerConstraintX = $0.alignToSuperview(.centerX).first
            self.endSpinnerConstraintY = $0.align(.centerY, to: endSpinner.superview!, for: .bottom, offset: -displacementToTriggerRefresh * 0.5).first
          }
        }
      default:
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal

        if let frontSpinner = frontSpinner {
          if let constraintX = frontSpinnerConstraintX { frontSpinner.removeConstraint(constraintX) }
          if let constraintY = frontSpinnerConstraintY { frontSpinner.removeConstraint(constraintY) }

          frontSpinner.autoLayout {
            self.frontSpinnerConstraintX = $0.alignToSuperview(.left, offset: 15.0).first
            self.frontSpinnerConstraintY = $0.alignToSuperview(.centerY).first
          }
        }

        if let endSpinner = endSpinner {
          if let constraintX = endSpinnerConstraintX { endSpinner.removeConstraint(constraintX) }
          if let constraintY = endSpinnerConstraintY { endSpinner.removeConstraint(constraintY) }

          endSpinner.autoLayout {
            self.endSpinnerConstraintX = $0.alignToSuperview(.right, offset: 15.0).first
            self.endSpinnerConstraintY = $0.alignToSuperview(.centerY).first
          }
        }
      }
    }

    if check.isDirty(.behavior) {
      collectionView.isScrollEnabled = isScrollEnabled

      switch orientation {
      case .vertical:
        collectionView.showsVerticalScrollIndicator = showsScrollIndicator
        collectionView.showsHorizontalScrollIndicator = false
      default:
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = showsScrollIndicator
      }
    }

    if check.isDirty(.mode) {
      // Stop the spinner in any data state other than "loading".
      switch dataState {
      case .loading(_):
        break
      case .error(error: _):
        selectedDataPool = [:]
        collectionView.reloadData()
        fallthrough
      default:
        stopFrontSpinner()
        stopEndSpinner()
      }

      switch selectionMode {
      case .multiple:
        collectionView.allowsMultipleSelection = true
        collectionView.allowsSelection = true
      case .single:
        // This is enabled for a reason. The native UICollectionView behaves weirdly, such that if
        // `allowsMultipleSelection` is `false`, and a cell has `collectionView:shouldSelectItemAt:`
        // returning `false`, the previously selected cell still gets deselected. Hence this custom
        // controller manually handles single selection restrictions.
        collectionView.allowsMultipleSelection = true
        collectionView.allowsSelection = true
      default:
        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = true
      }

      if let backgroundView = collectionView.backgroundView {
        let newPlaceholderView = placeholderView(for: dataState)
        newPlaceholderView?.accessibilityIdentifier = placeholderIdentifier(for: dataState)

        if
          let newId = newPlaceholderView?.accessibilityIdentifier,
          let oldId = placeholderView?.accessibilityIdentifier,
          newId == oldId
        {
          // Do nothing because they are the same.
        }
        else {
          placeholderView?.removeFromSuperview()
          placeholderView = nil

          // Handle transition in animation.
          if let placeholderView = newPlaceholderView {
            switch placeholderTransitionStyle {
            case .fade:
              placeholderView.alpha = 0.0

              UIView.transition(with: backgroundView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
                backgroundView.addSubview(placeholderView)
                placeholderView.alpha = 1.0
              }, completion: nil)
            case .slideUp:
              placeholderView.transform = CGAffineTransform(translationX: 0, y: 20)
              placeholderView.alpha = 0.0

              UIView.transition(with: backgroundView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
                backgroundView.addSubview(placeholderView)
                placeholderView.transform = CGAffineTransform(translationX: 0, y: 0)
                placeholderView.alpha = 1.0
              }, completion: nil)
            case .slideRight:
              placeholderView.transform = CGAffineTransform(translationX: -20, y: 0)
              placeholderView.alpha = 0.0

              UIView.transition(with: backgroundView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
                backgroundView.addSubview(placeholderView)
                placeholderView.transform = CGAffineTransform(translationX: 0, y: 0)
                placeholderView.alpha = 1.0
              }, completion: nil)
            case .slideDown:
              placeholderView.transform = CGAffineTransform(translationX: 0, y: -20)
              placeholderView.alpha = 0.0

              UIView.transition(with: backgroundView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
                backgroundView.addSubview(placeholderView)
                placeholderView.transform = CGAffineTransform(translationX: 0, y: 0)
                placeholderView.alpha = 1.0
              }, completion: nil)
            case .slideLeft:
              placeholderView.transform = CGAffineTransform(translationX: 20, y: 0)
              placeholderView.alpha = 0.0

              UIView.transition(with: backgroundView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
                backgroundView.addSubview(placeholderView)
                placeholderView.transform = CGAffineTransform(translationX: 0, y: 0)
                placeholderView.alpha = 1.0
              }, completion: nil)
            default:
              backgroundView.addSubview(placeholderView)
            }

            placeholderView.autoLayout {
              $0.alignToSuperview()
            }

            self.placeholderView = placeholderView
          }
        }
      }
    }

    if check.isDirty(.content) {
      if let indexPaths = collectionView.indexPathsForSelectedItems {
        for indexPath in indexPaths {
          guard
            let cell = collectionView.cellForItem(at: indexPath),
            let entry = hasDataFilter ? filteredDatum(at: indexPath) : datum(at: indexPath)
          else { continue }

          cell.isSelected = isDatumSelected(entry)
        }
      }
    }

    if check.isDirty(.style) {
      if let sectionSeparatorColor = sectionSeparatorColor {
        flowLayout.sectionSeparatorColor = sectionSeparatorColor
      }

      if let cellSeparatorColor = cellSeparatorColor {
        flowLayout.cellSeparatorColor = cellSeparatorColor
      }
    }
  }

  // MARK: - Data Management

  /// The current data state.
  @Stateful(.mode) public var dataState: DataState = .default {
    didSet {
      guard $dataState.isDirty else { return }
      delegate?.dataCollectionViewControllerDataStateDidChange(self)
    }
  }

  /// Filter to apply to the fetched data. Once set, the collection view will reload with data
  /// filtered by this value. How this value translates to data being filtered is up to the method
  /// `dataFilterPredicate(datum:for:filter:)`.
  public var dataFilter: Any? {
    didSet {
      reloadData(isFiltering: hasDataFilter, sender: self)
    }
  }

  /// Indicates if the collection currently has a valid data filter applied.
  public var hasDataFilter: Bool { dataFilter != nil }

  /// Predicate method used to iterate over every datum to determine if it should be included
  /// whenever the data filter changes. Return `true` to indicate that the datum should be included,
  /// `false` otherwise.
  ///
  /// - Parameters:
  ///   - datum: The datum to test for inclusion.
  ///   - section: Index of the section this datum belongs to.
  ///
  /// - Returns: `true` to include this datum, `false` otherwise.
  open func dataFilterPredicate(_ datum: T, for section: Int, filter: Any) -> Bool { false }

  /// Returns the data (plural, consisting of individual *datum*) at the specified section. It is
  /// best to override this method to fetch data from a view model or data provider.
  ///
  /// - Parameters:
  ///   - section: Section index.
  ///
  /// - Returns: The data at the specified section.
  open func data(for section: Int) -> [T]? {
    guard (section < numberOfSections) else { return nil }
    return []
  }

  /// Gets the datum (singular) at the specified index path.
  ///
  /// - Parameter:
  ///   - indexPath: The index path.
  ///
  /// - Returns: The datum.
  public func datum(at indexPath: IndexPath) -> T? {
    guard let data = self.data(for: indexPath.section) else { return nil }
    guard indexPath.item < data.count else { return nil }
    return data[indexPath.item]
  }

  /// Gets the filtered data (plural) at the specified section.
  ///
  /// - Parameters:
  ///   - section: Section index.
  ///
  /// - Returns: The filtered data at the specified section.
  public func filteredData(for section: Int) -> [T]? {
    let data = self.data(for: section)

    if hasDataFilter, let filter = dataFilter {
      return data?.filter { dataFilterPredicate($0, for: section, filter: filter) }
    }
    else {
      return data
    }
  }

  /// Gets the filtered datum (singular) at the specified index path.
  ///
  /// - Parameters:
  ///   - indexPath: Index path.
  ///
  /// - Returns: The filtered datum.
  public func filteredDatum(at indexPath: IndexPath) -> T? {
    guard let t = filteredData(for: indexPath.section), indexPath.item < t.count else { return nil }
    return t[indexPath.item]
  }

  /// Checks if two data (plural of datum) are equal (given that the data is expected to be
  /// equatable). Override this for custom comparisions.
  ///
  /// - Parameters:
  ///   - a: A datum.
  ///   - b: Another datum.
  ///
  /// - Returns: `true` if they're equal, `false` otherwise.
  public func areDataEqual(a: T, b: T) -> Bool { a == b }

  /// Gets the data count at the specified section.
  ///
  /// - Parameters:
  ///   - section: Section index.
  ///
  /// - Returns: The count.
  public func count(for section: Int, filtered: Bool? = nil) -> Int {
    if filtered ?? hasDataFilter {
      return filteredData(for: section)?.count ?? 0
    }
    else {
      return data(for: section)?.count ?? 0
    }
  }

  /// Reloads the data in the collection view. Call this instead of directly calling `reloadData()`
  /// on the collection view. Note that this is the private API for reloading data. Always call the
  /// public `refresh` method instead to trigger this.
  ///
  /// - Parameters:
  ///   - isFiltering: Specifies if the reload is triggered due to data filter changes. When
  ///                  filtering, the reload operation is much lighter.
  ///   - sender: The object that triggered the reload.
  private func reloadData(isFiltering: Bool, sender: Any?) {
    delegate?.dataCollectionViewControllerWillReloadData(self, sender: sender)

    collectionView.reloadData()

    // Scroll to beginning after reload data is done (which basically should be the next UI refresh
    // cycle) if filtering.
    if (isFiltering) {
      DispatchQueue.main.async {
        self.collectionView.setContentOffset(.zero, animated: false)
      }
    }

    // Restore previously selected data.
    switch selectionMode {
    case .single, .multiple:
      for (section, entries) in selectedDataPool {
        for entry in entries {
          if let index = firstIndex(for: entry, at: section) {
            selectCellInCollectionView(at: IndexPath(item: index, section: section))
          }
        }
      }
    default: break
    }

    // If filtering, nothing more to do, return here.
    guard !isFiltering else { return }

    // Only apply default selection if there are no selected cells at the moment. Also, do it in the
    // next run loop.
    if indexPathsForSelectedCells.count == 0 {
      DispatchQueue.main.async {
        self.applyDefaultSelection()
      }
    }

    // Update the data state depending on whether there is data displayed in the collection view.
    if dataState != .error(error: nil) {
      let n = Array(0 ..< numberOfSections).reduce(0, { $0 + count(for: $1) })
      dataState = n > 0 ? .hasData : .noData
    }

    delegate?.dataCollectionViewControllerDidReloadData(self, sender: sender)

    stateMachine.invalidate(.data)
  }

  /// Method that indicates if manual refresh is allowed per data state. Override this for custom
  /// behavior.
  ///
  /// - Parameters:
  ///   - dataState: The data state to check.
  ///
  /// - Returns: `true` to allow manual refresh, `false` otherwise.
  open func collectionViewWillPullToRefreshInDataState(_ dataState: DataState) -> Bool { false }

  // MARK: - Selection Management

  /// Specifies how the collection view selects its cells.
  @Stateful(.mode) public var selectionMode: SelectionMode = .none

  /// Specifies whether a cell should deselect when selecting it again, only works if
  /// `selectionMode` is not `none`.
  public var allowsTogglingSelectedCells: Bool = false

  /// Pool of selected data indexed by section.
  private var selectedDataPool: [Int: [T]] = [:]

  /// Index paths for all currently selected cells.
  public var indexPathsForSelectedCells: [IndexPath] { return collectionView.indexPathsForSelectedItems ?? [] }

  /// Index path of the single selected cell (when `selectionMode` is `single`).
  public var indexPathForSelectedCell: IndexPath? {
    guard indexPathsForSelectedCells.count == 1 else { return nil }
    return indexPathsForSelectedCells.first
  }

  /// The currently selected data (plural).
  public var selectedData: [T] {
    return selectedDataPool.reduce([], { out, curr in
      return out + curr.value
    })
  }

  /// The currently selected datum (singular).
  public var selectedDatum: T? {
    guard selectedData.count == 1 else { return nil }
    return selectedData.first
  }

  /// Checks to see if a cell is selected at the specified index path.
  ///
  /// - Parameter indexPath: The index path.
  ///
  /// - Returns: `true` if selected, `false` otherwise.
  public func isCellSelected(at indexPath: IndexPath) -> Bool {
    return indexPathsForSelectedCells.contains(indexPath)
  }

  /// Checks to see if a datum is selected.
  ///
  /// - Parameters:
  ///   - datum: The datum.
  ///
  /// - Returns: `true` if it is selcted, `false` otherwise.
  public func isDatumSelected(_ datum: T) -> Bool {
    for (_, pool) in selectedDataPool {
      if (pool.firstIndex { areDataEqual(a: $0, b: datum) }) != nil {
        return true
      }
    }

    return false
  }

  /// Selects a cell at the specified index path, with the option to scroll to it (positioning it at
  /// the center of the collection view).
  ///
  /// - Parameters:
  ///   - indexPath: The target index path for the cell to select.
  ///   - shouldScroll: Specifies whether to scroll to the cell at the target index path.
  ///   - animated: Whether the scroll is animated.
  public func select(_ indexPath: IndexPath, shouldScroll: Bool = true, animated: Bool = true) {
    guard shouldSelectCellAt(indexPath) else { return }

    let shouldAnimate = hasViewAppeared ? shouldScroll && animated : false

    switch orientation {
    case .vertical:
      let scrollPosition: UICollectionView.ScrollPosition = (indexPath.section == 0 && indexPath.item == 0) ? .top : .centeredVertically
      selectCellInCollectionView(at: indexPath, animated: shouldAnimate, scrollPosition: shouldScroll ? scrollPosition : nil)
    default:
      let scrollPosition: UICollectionView.ScrollPosition = (indexPath.section == 0 && indexPath.item == 0) ? .left : .centeredHorizontally
      selectCellInCollectionView(at: indexPath, animated: shouldAnimate, scrollPosition: shouldScroll ? scrollPosition : nil)
    }

    enqueueSelectedDatum(at: indexPath)
    selectionDidChange()
  }

  /// Selects a cell by its associated datum. If the same datum is associated with more than one
  /// cell and `selectionMode` is `single`, the first matching cell will be selected. If
  /// `selectionMode` is `multiple`, all the matching cells will be selected.
  ///
  /// - Parameters:
  ///   - datum: The datum to select.
  ///   - shouldScroll: Specifies whether to scroll to the collection cell.
  ///   - animated: Whether the scroll is animated.
  public func select(_ datum: T, shouldScroll: Bool = true, animated: Bool = true) {
    var count = 0

    // Select it on the collection view if it's there.
    switch selectionMode {
    case .single:
      if let indexPath = firstIndexPath(for: datum), shouldSelectCellAt(indexPath) {
        let shouldAnimate = hasViewAppeared ? shouldScroll && animated : false

        switch orientation {
        case .vertical:
          let scrollPosition: UICollectionView.ScrollPosition = (indexPath.section == 0 && indexPath.item == 0) ? .top : .centeredVertically
          selectCellInCollectionView(at: indexPath, animated: shouldAnimate, scrollPosition: shouldScroll ? scrollPosition : nil)
        default:
          let scrollPosition: UICollectionView.ScrollPosition = (indexPath.section == 0 && indexPath.item == 0) ? .left : .centeredHorizontally
          selectCellInCollectionView(at: indexPath, animated: shouldAnimate, scrollPosition: shouldScroll ? scrollPosition : nil)
        }

        count += 1
      }
    case .multiple:
      for indexPath in indexPaths(for: datum) {
        guard shouldSelectCellAt(indexPath) else { continue }

        selectCellInCollectionView(at: indexPath)

        count += 1
      }
    default: return
    }

    // Regardless of whether it's visible in the collection view, mark the data itself as selected
    // when at least one of its cells is selected.
    if count > 0 {
      enqueueSelectedDatum(datum)
      selectionDidChange()
    }
  }

  /// Selects all cells at the specified section.
  ///
  /// - Parameters:
  ///   - section: Section index.
  public func selectAll(at section: Int) {
    guard selectionMode == .multiple else { return }
    guard let data = filteredData(for: section) else { return }

    var count = 0

    for i in 0..<data.count {
      let indexPath = IndexPath(item: i, section: section)

      guard shouldSelectCellAt(indexPath) else { continue }

      count += 1

      selectCellInCollectionView(at: indexPath)
      enqueueSelectedDatum(at: indexPath)
    }

    if count > 0 {
      selectionDidChange()
    }
  }

  /// Proxy method for selecting a cell in the collection view.
  ///
  /// - Parameters:
  ///   - indexPath: The index path of the cell to select in the collection view.
  ///   - animated: Specifies if the selection is animated.
  ///   - scrollPosition: Specifies the scroll position of the selection, `nil` to leave current
  ///                     scroll position unchanged.
  private func selectCellInCollectionView(at indexPath: IndexPath, animated: Bool = false, scrollPosition: UICollectionView.ScrollPosition? = nil) {
    if selectionMode == .single {
      for ip in collectionView.indexPathsForSelectedItems ?? [] {
        guard ip != indexPath else { continue }
        deselectCellInCollectionView(at: ip, animated: false)
        dequeueSelectedDatum(at: ip)
      }
    }

    collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition ??  .init(rawValue: 0))
  }

  /// Deselects a cell at the specified index path.
  ///
  /// - Parameters:
  ///   - indexPath: The target index path for the cell to deselect.
  public func deselect(_ indexPath: IndexPath) {
    guard shouldDeselectCellAt(indexPath) else { return }

    deselectCellInCollectionView(at: indexPath, animated: false)
    dequeueSelectedDatum(at: indexPath)

    selectionDidChange()
  }

  /// Deselects a cell by its associated datum. If the same datum is associated with more than one
  /// cell and the `selectionMode` is `single`, the first matching cell will be deselected. If
  /// `selectionMode` is `multiple`, all the matching cells will be deselected.
  ///
  /// - Parameters:
  ///   - datum: The data to deselect.
  public func deselect(_ datum: T) {
    var count = 0

    // Select it on the collection view if it's there.
    switch selectionMode {
    case .single:
      if let indexPath = firstIndexPath(for: datum), shouldDeselectCellAt(indexPath) {
        deselectCellInCollectionView(at: indexPath, animated: false)
        count += 1
      }
    case .multiple:
      for indexPath in indexPaths(for: datum) {
        guard shouldDeselectCellAt(indexPath) else { continue }
        deselectCellInCollectionView(at: indexPath, animated: false)
        count += 1
      }
    default: return
    }

    // Regardless of whether it's visible in the collection view, mark the data itself as deselected
    // when at least one of its cells is deselected.
    if count > 0 {
      dequeueSelectedDatum(datum)
      selectionDidChange()
    }
  }

  /// Deselects all cells at the specified section.
  ///
  /// - Parameters:
  ///   - section: Section index.
  public func deselectAll(at section: Int) {
    guard
      selectionMode != .none,
      indexPathsForSelectedCells.count > 0
      else { return }

    guard let data = filteredData(for: section) else { return }

    var count = 0

    for i in 0..<data.count {
      let indexPath = IndexPath(item: i, section: section)

      guard shouldDeselectCellAt(indexPath) else { continue }

      count += 1

      deselectCellInCollectionView(at: indexPath, animated: false)
      dequeueSelectedDatum(at: indexPath)
    }

    if count > 0 {
      selectionDidChange()
    }
  }

  /// Proxy method for deselecting a cell in the collection view.
  ///
  /// - Parameters:
  ///   - indexPath: The index path of the cell to deselect in the colleciton view.
  ///   - animated: Specifies if the deselection is animated.
  private func deselectCellInCollectionView(at indexPath: IndexPath, animated: Bool) {
    collectionView.deselectItem(at: indexPath, animated: animated)
  }

  /// Specifies if the cell at the specified index path should be selected. This is invoked when the
  /// cell is manually selected via user input and when default selection is applied.
  ///
  /// - Parameters:
  ///   - indexPath: The index path of the cell.
  ///
  /// - Returns: `true` or `false`.
  open func shouldSelectCellAt(_ indexPath: IndexPath) -> Bool {
    guard
      selectionMode != .none,
      indexPath.section < numberOfSections,
      indexPath.item < collectionView.numberOfItems(inSection: indexPath.section)
    else { return false }

    return true
  }

  /// Specifies if the cell at the specified index path should be deselected. This is only invoked
  /// when the cell is manually deselected via user input.
  ///
  /// - Parameter indexPath: The index path of the cell.
  ///
  /// - Returns: `true` or `false`.
  open func shouldDeselectCellAt(_ indexPath: IndexPath) -> Bool {
    guard
      selectionMode != .none,
      indexPath.section < numberOfSections,
      indexPath.item < collectionView.numberOfItems(inSection: indexPath.section)
    else { return false }

    return allowsTogglingSelectedCells || (selectionMode == .multiple)
  }

  /// Marks the datum at the specified index path as selected.
  ///
  /// - Parameters:
  ///   - indexPath: The index path of the datum.
  private func enqueueSelectedDatum(at indexPath: IndexPath) {
    guard selectionMode != .none else { return }

    if let datum = hasDataFilter ? filteredDatum(at: indexPath) : datum(at: indexPath) {
      switch selectionMode {
      case .single:
        selectedDataPool = [indexPath.section: [datum]]
      case .multiple:
        if selectedDataPool[indexPath.section] == nil {
          selectedDataPool[indexPath.section] = [datum]
        }
        else if selectedDataPool[indexPath.section]?.firstIndex(where: { areDataEqual(a: datum, b: $0) }) == nil {
          selectedDataPool[indexPath.section]?.append(datum)
        }
      default: break
      }
    }
  }

  /// Marks a datum as selected. This method handles duplicate data as well, so the same datum
  /// across multiple sections will all be marked as selected.
  ///
  /// - Parameters:
  ///   - datum: The datum.
  private func enqueueSelectedDatum(_ datum: T) {
    switch selectionMode {
    case .single:
      if let indexPath = self.firstIndexPath(for: datum) {
        selectedDataPool = [indexPath.section: [datum]]
      }
    case .multiple:
      let sections = Array(Set(indexPaths(for: datum).map { $0.section }))

      for section in sections {
        if selectedDataPool[section] == nil {
          selectedDataPool[section] = [datum]
        }
        else if selectedDataPool[section]?.firstIndex(where: { areDataEqual(a: datum, b: $0) }) == nil {
          selectedDataPool[section]?.append(datum)
        }
      }
    default: break
    }
  }

  /// Marks the datum at the specified index path as deselected.
  ///
  /// - Parameters:
  ///   - indexPath: The index path of the datum.
  private func dequeueSelectedDatum(at indexPath: IndexPath) {
    guard selectionMode != .none else { return }

    guard selectedDataPool[indexPath.section] != nil, let datum = hasDataFilter ? filteredDatum(at: indexPath) : datum(at: indexPath), isDatumSelected(datum) else { return }

    switch selectionMode {
    case .single:
      selectedDataPool = [:]
    case .multiple:
      if let index = (selectedDataPool[indexPath.section]?.firstIndex { areDataEqual(a: datum, b: $0) }) {
        selectedDataPool[indexPath.section]?.remove(at: index)
      }
    default: break
    }
  }

  /// Marks a datum as deselected. This method handles duplicate data as well, so the same datum
  /// across multiple sections will all be marked as deselected.
  ///
  /// - Parameters:
  ///   - datum: The datum.
  private func dequeueSelectedDatum(_ datum: T) {
    switch selectionMode {
    case .single:
      if
        let indexPath = self.firstIndexPath(for: datum),
        selectedDataPool[indexPath.section] != nil,
        isDatumSelected(datum)
      {
        selectedDataPool = [:]
      }
    case .multiple:
      for (section, pool) in selectedDataPool {
        selectedDataPool[section] = pool.filter { !areDataEqual(a: datum, b: $0) }
      }
    default: break
    }
  }

  /// Applies default cell selection(s). This is invoked upon initial load and subsequent reloads of
  /// the collection view.
  private func applyDefaultSelection() {
    switch selectionMode {
    case .single:
      guard let selectedData = delegate?.dataCollectionViewControllerWillApplyDefaultSelection(self) as? T, let indexPath = firstIndexPath(for: selectedData) else { return }

      if shouldSelectCellAt(indexPath) {
        selectCellInCollectionView(at: indexPath, scrollPosition: orientation == .vertical ? .centeredVertically : .centeredHorizontally)
        enqueueSelectedDatum(at: indexPath)
      }
      else {
        scrollToCell(at: indexPath, animated: false)
      }

      delegate?.dataCollectionViewControllerDidApplyDefaultSelection(self)
    case .multiple:
      guard let selectedData = delegate?.dataCollectionViewControllerWillApplyDefaultSelection(self) as? [T] else { return }

      for data in selectedData {
        guard let indexPath = firstIndexPath(for: data), shouldSelectCellAt(indexPath) else { continue }
        selectCellInCollectionView(at: indexPath, scrollPosition: .init(rawValue: 0))
        enqueueSelectedDatum(at: indexPath)
      }

      delegate?.dataCollectionViewControllerDidApplyDefaultSelection(self)
    case .none: return
    }
  }

  /// Handler invoked when cell selection changes.
  private func selectionDidChange() {
    stateMachine.invalidate(.content)
    delegate?.dataCollectionViewControllerSelectionDidChange(self)
  }

  final public override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    delegate?.dataCollectionViewController(self, didTapOnCellAt: indexPath)
    return shouldSelectCellAt(indexPath)
  }

  final public override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    return shouldDeselectCellAt(indexPath)
  }

  final public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if selectionMode == .single {
      for ip in collectionView.indexPathsForSelectedItems ?? [] {
        guard ip != indexPath else { continue }
        deselectCellInCollectionView(at: ip, animated: false)
        dequeueSelectedDatum(at: ip)
      }
    }

    enqueueSelectedDatum(at: indexPath)
    selectionDidChange()
  }

  /// - Note: This handler is only invoked when the collection view allows multiple selections.
  final public override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    dequeueSelectedDatum(at: indexPath)
    selectionDidChange()
  }

  // MARK: - Cell Management

  /// Creates and initializes the cell at the specified index path. This is a good place to dequeue
  /// reusable cells. Derived classes MUST implement this method.
  ///
  /// - Parameters:
  ///   - indexPath: The index path.
  ///
  /// - Returns: The cell.
  open func cellFactory(at indexPath: IndexPath) -> UICollectionViewCell { fatalError("Derived class must implement this method") }

  /// Initializes a cell instance. Override this to provide additional initialization steps.
  ///
  /// - Parameters:
  ///   - cell: The cell instance.
  ///   - indexPath: The index path of the cell.
  open func initCell(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
    cell.isSelected = indexPathsForSelectedCells.contains(indexPath)
  }

  final public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = cellFactory(at: indexPath)
    initCell(cell, at: indexPath)
    return delegate?.dataCollectionViewController(self, didInitCell: cell, at: indexPath) ?? cell
  }

  // MARK: - Layout Management

  /// Orientation of the collection view.
  @Stateful(.layout) public var orientation: UICollectionView.ScrollDirection = .horizontal

  /// Alignment of cells in the collection view.
  @Stateful(.layout) public var cellAlignment: CellAlignment = .start

  /// Style of the separators.
  @Stateful(.layout) public var separatorStyle: SeparatorStyle = .none

  /// The content insets of the collection view.
  @Stateful(.layout) public var contentInsets: UIEdgeInsets = .zero

  /// Color of the section separators, `nil` translates to a transparent color.
  @Stateful(.style) public var sectionSeparatorColor: UIColor? = nil

  /// Color of the cell separators, `nil` translates to a transparent color.
  @Stateful(.style) public var cellSeparatorColor: UIColor? = nil

  /// Edge insets of each section.
  open var sectionInsets: UIEdgeInsets { return .zero }

  /// Space between each cell within a section.
  open var cellSpacing: CGFloat { return 0.0 }

  /// Width of the section separators.
  @Stateful(.layout) open var sectionSeparatorWidth: CGFloat = 1.0

  /// Width of the cell separators.
  @Stateful(.layout) open var cellSeparatorWidth: CGFloat = 1.0

  /// The number of sections in the collection view.
  open var numberOfSections: Int { return collectionView.numberOfSections }

  /// Custom flow layout for the collection view.
  private let flowLayout = DataCollectionViewFlowLayout()

  /// Index path of the nearest visible cell.
  public var indexPathForNearestVisibleCell: IndexPath? {
    var out: IndexPath?
    var delta: CGFloat = .greatestFiniteMagnitude

    switch orientation {
    case .vertical:
      let centerY: CGFloat = collectionView.contentOffset.y + collectionView.bounds.size.height * 0.5

      for cell in collectionView.visibleCells{
        let cellHeight = cell.bounds.height
        let cellCenterY: CGFloat = cell.frame.minY + cellHeight * 0.5
        let distance = CGFloat(fabsf(Float(centerY) - Float(cellCenterY)))

        if distance < delta, let indexPath = collectionView.indexPath(for: cell) {
          delta = distance
          out = indexPath
        }
      }
    default:
      let centerX: CGFloat = collectionView.contentOffset.x + collectionView.bounds.size.width * 0.5

      for cell in collectionView.visibleCells {
        let cellWidth = cell.bounds.width
        let cellCenterX: CGFloat = cell.frame.minX + cellWidth * 0.5
        let distance = CGFloat(fabsf(Float(centerX) - Float(cellCenterX)))

        if distance < delta, let indexPath = collectionView.indexPath(for: cell) {
          delta = distance
          out = indexPath
        }
      }
    }

    return out
  }

  open override func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // Update bounds of the spinners.
    if let mask = frontSpinnerMask, let spinner = frontSpinner {
      mask.bounds = spinner.bounds
      mask.frame = spinner.bounds
    }

    if let mask = endSpinnerMask, let spinner = endSpinner {
      mask.bounds = spinner.bounds
      mask.frame = spinner.bounds
    }
  }

  /// Gets the cell size of this collection view for a cell at the specified index path.
  ///
  /// - Parameters:
  ///   - indexPath: Cell index path.
  ///
  /// - Returns: The size.
  open func cellSize(for indexPath: IndexPath) -> CGSize { return .zero }

  open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return count(for: section) }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { return cellSize(for: indexPath) }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

    switch (orientation) {
    case .horizontal:
      let cellWidth = cellSize(for: IndexPath(item: 0, section: section)).width
      let cellCount = Array(0 ..< collectionView.numberOfSections).reduce(0, { $0 + count(for: $1) })
      let totalCellWidth = cellWidth * CGFloat(cellCount)
      let totalCellSpacing = cellSpacing * CGFloat(cellCount > 0 ? (cellCount - 1) : 0)

      switch cellAlignment {
      case .start:
        return sectionInsets
      case .center:
        let leftInset = (collectionView.frame.width - totalCellWidth - totalCellSpacing) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0.0, left: max(sectionInsets.left, leftInset), bottom: 0.0, right: max(sectionInsets.right, rightInset))
      case .end:
        let leftInset = collectionView.frame.width - totalCellWidth - totalCellSpacing
        return UIEdgeInsets(top: 0.0, left: max(sectionInsets.left, leftInset), bottom: 0.0, right: sectionInsets.right)
      }
    case .vertical:
      let cellHeight = cellSize(for: IndexPath(item: 0, section: section)).height
      let cellCount = Array(0 ..< collectionView.numberOfSections).reduce(0, { $0 + count(for: $1) })
      let totalCellHeight = cellHeight * CGFloat(cellCount)
      let totalCellSpacing = cellSpacing * CGFloat(cellCount > 0 ? (cellCount - 1) : 0)

      switch cellAlignment {
      case .start:
        return sectionInsets
      case .center:
        let topInset = (collectionView.frame.height - totalCellHeight - totalCellSpacing) / 2
        let bottomInset = topInset
        return UIEdgeInsets(top: max(sectionInsets.top, topInset), left: 0.0, bottom: max(sectionInsets.bottom, bottomInset), right: 0.0)
      case .end:
        let topInset = collectionView.frame.height - totalCellHeight - totalCellSpacing
        return UIEdgeInsets(top: max(sectionInsets.top, topInset), left: 0.0, bottom: sectionInsets.bottom, right: 0.0)
      }
    @unknown default:
      return sectionInsets
    }
  }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return cellSpacing }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return cellSpacing }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { return .zero }

  // MARK: - Scrolling

  /// Specifies if scrolling is enabled (relative to the orientation).
  @Stateful(.behavior) public var isScrollEnabled: Bool = true

  /// Specifies if scroll indicators are visible (relative to the orientation).
  @Stateful(.behavior) public var showsScrollIndicator: Bool = true

  /// Specifies whether the collection will refresh automatically on initial load.
  public var shouldRefreshOnLoad: Bool = true

  /// Scrolls to the beginning of the collection.
  ///
  /// - Parameters:
  ///   - animated: Specifies if the scrolling is animated.
  public func scrollToBeginning(animated: Bool) {
    collectionView.setContentOffset(collectionView.minContentOffset, animated: animated)
  }

  /// Scrolls to the end of the collection.
  ///
  /// - Parameters:
  ///   - animated: Specifies if the scrolling is animated.
  public func scrollToEnd(animated: Bool) {
    collectionView.setContentOffset(collectionView.maxContentOffset, animated: animated)
  }

  /// Scrolls to a cell at the specified index path.
  ///
  /// - Parameters:
  ///   - indexPath: The index path of the cell in the collection view.
  ///   - animated: Specifies if the scrolling is animated.
  public func scrollToCell(at indexPath: IndexPath, animated: Bool = true) {
    collectionView.scrollToItem(at: indexPath, at: orientation == .vertical ? .centeredVertically : .centeredHorizontally, animated: animated)
  }

  /// Scrolls to the first cell with the specified datum.
  ///
  /// - Parameters:
  ///   - datum: The datum of the cell.
  ///   - animated: Specifies if the scrolling is animated.
  public func scrollToDatum(_ datum: T, animated: Bool = true) {
    guard let indexPath = firstIndexPath(for: datum) else { return }
    scrollToCell(at: indexPath, animated: animated)
  }

  open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if collectionViewWillPullToRefreshInDataState(dataState) { layoutSpinnersIfNeeded() }
    delegate?.dataCollectionViewControllerDidScroll(self)
  }

  open override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    if collectionViewWillPullToRefreshInDataState(dataState) {
      var frontDelta: CGFloat = 0.0
      var endDelta: CGFloat = 0.0

      switch orientation {
      case .vertical:
        frontDelta = min(0.0, scrollView.contentOffset.y - scrollView.minContentOffset.y)
        endDelta = max(0.0, scrollView.contentOffset.y - scrollView.maxContentOffset.y)
      default:
        frontDelta = min(0.0, scrollView.contentOffset.x - scrollView.minContentOffset.x)
        endDelta = max(0.0, scrollView.contentOffset.x - scrollView.maxContentOffset.x)
      }

      if frontDelta < -displacementToTriggerRefresh {
        startFrontSpinner()
      }

      if canPullToRefreshAtEndOfCollection, endDelta > displacementToTriggerRefresh {
        startEndSpinner()
      }
    }
  }

  open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    // Invalidate the dirty flag for content so cell selection can take effect. If you mark a cell
    // as selected and scroll to it, it is sometimes semi-visible (you can see it but the collection
    // view thinks it's invisible because `cellForItem(at:)` is `nil`), hence the selection will not
    // apply, so do this at the end of a scrolling animation.
    stateMachine.invalidate(.content)
  }

  // MARK: - Pull-to-Refresh Management

  /// Distance required to overscroll in order to trigger a refresh (consequently showing the
  /// spinner). This value INCLUDES the content insets of the collection view.
  public var displacementToTriggerRefresh: CGFloat = 60.0

  /// Specifies whether user can pull to refresh at end of collection (as oppposed to only the
  /// front).
  public var canPullToRefreshAtEndOfCollection: Bool = true

  /// Refresh control spinner at the front of the collection view.
  public var frontSpinner: DataCollectionViewSpinner? {
    willSet {
      if let oldSpinner = frontSpinner {
        oldSpinner.removeFromSuperview()
        frontSpinnerMask = nil
      }
    }

    didSet {
      if let backgroundView = collectionView.backgroundView, let newSpinner = frontSpinner {
        backgroundView.addSubview(newSpinner)

        let mask = CAGradientLayer()
        mask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        // HACK: Somehow when the start and end points are identical, the layer mask doesn't work at
        // all.
        mask.startPoint = CGPoint(x: -0.01, y: 0.5)
        mask.endPoint = CGPoint(x: 0.0, y: 0.5)
        newSpinner.layer.mask = mask
        frontSpinnerMask = mask

        stateMachine.invalidate(.layout)
      }
    }
  }

  /// Gradient mask of the refresh control spinner at the end of the collection view.
  private var frontSpinnerMask: CAGradientLayer?

  /// X constraint of the front spinner.
  private var frontSpinnerConstraintX: NSLayoutConstraint?

  /// Y constraint of the front spinner.
  private var frontSpinnerConstraintY: NSLayoutConstraint?

  /// Refresh control spinner at the end of the collection view.
  public var endSpinner: DataCollectionViewSpinner? {
    willSet {
      if let oldSpinner = endSpinner {
        oldSpinner.removeFromSuperview()
        endSpinnerMask = nil
      }
    }

    didSet {
      if let backgroundView = collectionView.backgroundView, let newSpinner = endSpinner {
        backgroundView.addSubview(newSpinner)

        let mask = CAGradientLayer()
        mask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        mask.startPoint = CGPoint(x: 1.01, y: 0.5)
        mask.endPoint = CGPoint(x: 1.0, y: 0.5)
        newSpinner.layer.mask = mask

        endSpinnerMask = mask

        stateMachine.invalidate(.layout)
      }
    }
  }

  /// Gradient mask of the refresh control spinner at the end of the collection view.
  private var endSpinnerMask: CAGradientLayer?

  /// X constraint of the end spinner.
  private var endSpinnerConstraintX: NSLayoutConstraint?

  /// Y constraint of the end spinner.
  private var endSpinnerConstraintY: NSLayoutConstraint?

  /// Starts the refresh control spinner at the front of the collection.
  private func startFrontSpinner() {
    guard let frontSpinner = frontSpinner, !frontSpinner.isActive, endSpinner?.isActive != true, collectionViewWillPullToRefreshInDataState(dataState) else { return }

    frontSpinner.isActive = true
    frontSpinnerMask?.endPoint = CGPoint(x: 2.0, y: 0.5)

    var insets = contentInsets

    switch orientation {
    case .vertical:
      insets.top = displacementToTriggerRefresh
    default:
      insets.left = displacementToTriggerRefresh
    }

    // Refresh is triggered by pulling the scroll view. When that happens and user releases the
    // pull, animate position of the scroll view just by the spinner while it is spinning.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = insets
      }, completion: nil)

      var offset = self.collectionView.contentOffset

      switch self.orientation {
      case .vertical:
        offset.y = self.collectionView.minContentOffset.y
      default:
        offset.x = self.collectionView.minContentOffset.x
      }

      self.collectionView.setContentOffset(offset, animated: true)
    }

    refresh(sender: self)
  }

  /// Stops the refresh control spinner at the front of the collection view.
  ///
  /// - Parameters:
  ///   - completion: Handle invoked upon completion.
  private func stopFrontSpinner(completion: (() -> Void)? = nil) {
    guard let frontSpinner = frontSpinner, frontSpinner.isActive else {
      completion?()
      return
    }

    frontSpinner.isActive = false
    frontSpinnerMask?.endPoint = CGPoint(x: 0.0, y: 0.5)

    // Play collapsing animation in the next UI cycle to avoid choppiness.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = self.contentInsets
      }) { _ in
        completion?()
      }
    }
  }

  /// Starts the refresh control spinner at the end of the collection.
  private func startEndSpinner() {
    guard let endSpinner = endSpinner, frontSpinner?.isActive != true, !endSpinner.isActive, canPullToRefreshAtEndOfCollection, collectionViewWillPullToRefreshInDataState(dataState) else { return }

    endSpinner.isActive = true
    endSpinnerMask?.endPoint = CGPoint(x: -1.0, y: 0.5)

    var insets = contentInsets

    switch orientation {
    case .vertical:
      insets.bottom = displacementToTriggerRefresh
    default:
      insets.right = displacementToTriggerRefresh
    }

    // Refresh is triggered by pulling the scroll view. When that happens and user releases the
    // pull, animate position of the scroll view just by the spinner while it is spinning.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = insets
      }, completion: nil)

      var offset = self.collectionView.contentOffset

      switch self.orientation {
      case .vertical:
        offset.y = self.collectionView.maxContentOffset.y
      default:
        offset.x = self.collectionView.maxContentOffset.x
      }

      self.collectionView.setContentOffset(offset, animated: true)
    }

    refresh(sender: self)
  }

  /// Stops the refresh control spinner at the end of the collection view.
  ///
  /// - Parameters:
  ///   - completion: Handle invoked upon completion.
  private func stopEndSpinner(completion: (() -> Void)? = nil) {
    guard let endSpinner = endSpinner, endSpinner.isActive else {
      completion?()
      return
    }

    endSpinner.isActive = false
    endSpinnerMask?.endPoint = CGPoint(x: 1.0, y: 0.5)

    // Play collapsing animation in the next UI cycle to avoid choppiness.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = self.contentInsets
      }) { _ in
        completion?()
      }
    }
  }

  /// Update layout of spinners if needed.
  private func layoutSpinnersIfNeeded() {
    switch orientation {
    case .vertical:
      // Content offset of scrollview should be < 0
      let frontDelta: CGFloat = min(0.0, collectionView.contentOffset.y - collectionView.minContentOffset.y)
      frontSpinnerMask?.endPoint = CGPoint(x: min(1.0, abs(frontDelta / displacementToTriggerRefresh)) * 2.0, y: 0.5)

      if canPullToRefreshAtEndOfCollection {
        // Content offset of scrollview should be > 0
        let endDelta: CGFloat = max(0.0, collectionView.contentOffset.y - collectionView.maxContentOffset.y)
        endSpinnerMask?.endPoint = CGPoint(x: 1.0 - min(1.0, abs(endDelta / displacementToTriggerRefresh)) * 2.0, y: 0.5)
      }
    default:
      // Content offset of scrollview should be < 0
      let frontDelta: CGFloat = min(0.0, collectionView.contentOffset.x - collectionView.minContentOffset.x)
      frontSpinnerMask?.endPoint = CGPoint(x: min(1.0, abs(frontDelta / displacementToTriggerRefresh)) * 2.0, y: 0.5)

      if canPullToRefreshAtEndOfCollection {
        // Content offset of scrollview should be > 0
        let endDelta: CGFloat = max(0.0, collectionView.contentOffset.x - collectionView.maxContentOffset.x)
        endSpinnerMask?.endPoint = CGPoint(x: 1.0 - min(1.0, abs(endDelta / displacementToTriggerRefresh)) * 2.0, y: 0.5)
      }
    }
  }

  // MARK: - Placeholder Management

  /// Transition style of the placeholders.
  public var placeholderTransitionStyle: PlaceholderTransitionStyle = .none

  /// The placeholder view.
  public private(set) weak var placeholderView: UIView?

  /// Gets the placeholder view identifier for the specified data state. This identifier is used to
  /// determine if 2 placeholders are the "same" so we can avoid transitioning one placeholder to
  /// another if they are the "same".
  ///
  /// - Parameters:
  ///   - dataState: The data state.
  ///
  /// - Returns: The identifier.
  open func placeholderIdentifier(for dataState: DataState) -> String {
    return "\(dataState)"
  }

  /// Gets the placeholder view for the specified data state. This is meant to be overridden.
  ///
  /// - Parameters:
  ///   - dataState: The target data state.
  ///
  /// - Returns: The placeholder view.
  open func placeholderView(for dataState: DataState) -> UIView? {
    return nil
  }
}
