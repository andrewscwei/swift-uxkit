//// © GHOZT
//
//import BaseKit
//import UIKit
//
//open class Foo<T: Equatable>: UICollectionViewController, UICollectionViewDelegateFlowLayout, StateMachineDelegate {
//
//  // MARK: - Life Cycle
//
//  required public init?(coder aDecoder: NSCoder) {
//    self.lockQueue = DispatchQueue(label: "sh.ghozt.uxkit.Foo.\(Self.self).lock-queue", qos: .utility)
//    self.fetchQueue = DispatchQueue(label: "sh.ghozt.uxkit.Foo.\(Self.self).fetch-queue", qos: .utility, attributes: .concurrent)
//    super.init(coder: aDecoder)
//    initSubviews()
//  }
//
//  public init() {
//    self.lockQueue = DispatchQueue(label: "sh.ghozt.uxkit.Foo.\(Self.self)", qos: .utility)
//    self.fetchQueue = DispatchQueue(label: "sh.ghozt.uxkit.Foo.\(Self.self).fetch-queue", qos: .utility, attributes: .concurrent)
//    super.init(collectionViewLayout: flowLayout)
//  }
//
//  override init(collectionViewLayout layout: UICollectionViewLayout) {
//    fatalError("<\(Self.self)> Restricted use of this initializer because Foo uses a custom UICollectionViewLayout")
//  }
//
//  func initSubviews() {
//    collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
//  }
//
//  open override func viewDidLoad() {
//    super.viewDidLoad()
//
//    // Set default properties.
//    collectionView.delegate = self
//    collectionView.bounces = true
//    collectionView.contentInsetAdjustmentBehavior = .never
//    collectionView.backgroundColor = .clear
//    collectionView.backgroundView = UIView()
//    collectionView.autoLayout { $0.alignToSuperview() }
//  }
//
//  open override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//
//    stateMachine.start()
//
//    if shouldAutoReload {
//      reloadData()
//    }
//  }
//
//  open override func viewDidDisappear(_ animated: Bool) {
//    super.viewDidDisappear(animated)
//
//    stateMachine.stop()
//  }
//
//  // MARK: - Updating
//
//  open func update(check: StateValidator) {
//    if check.isDirty(\Foo.orientation, \Foo.cellAlignment, \Foo.separatorStyle, \Foo.contentInsets, \Foo.sectionSeparatorWidth, \Foo.cellSeparatorWidth, \Foo.frontSpinner, \Foo.endSpinner) {
//      collectionView.contentInset = contentInsets
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
//
//        if let frontSpinner = frontSpinner {
//          if let constraintX = frontSpinnerConstraintX { frontSpinner.removeConstraint(constraintX) }
//          if let constraintY = frontSpinnerConstraintY { frontSpinner.removeConstraint(constraintY) }
//
//          frontSpinner.autoLayout {
//            self.frontSpinnerConstraintX = $0.alignToSuperview(.centerX).first
//            self.frontSpinnerConstraintY = $0.align(.centerY, to: frontSpinner.superview!, for: .top, offset: displacementToTriggerReload * 0.5).first
//          }
//        }
//
//        if let endSpinner = endSpinner {
//          if let constraintX = endSpinnerConstraintX { endSpinner.removeConstraint(constraintX) }
//          if let constraintY = endSpinnerConstraintY { endSpinner.removeConstraint(constraintY) }
//
//          endSpinner.autoLayout {
//            self.endSpinnerConstraintX = $0.alignToSuperview(.centerX).first
//            self.endSpinnerConstraintY = $0.align(.centerY, to: endSpinner.superview!, for: .bottom, offset: -displacementToTriggerReload * 0.5).first
//          }
//        }
//      default:
//        collectionView.alwaysBounceHorizontal = true
//        collectionView.alwaysBounceVertical = false
//        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
//
//        if let frontSpinner = frontSpinner {
//          if let constraintX = frontSpinnerConstraintX { frontSpinner.removeConstraint(constraintX) }
//          if let constraintY = frontSpinnerConstraintY { frontSpinner.removeConstraint(constraintY) }
//
//          frontSpinner.autoLayout {
//            self.frontSpinnerConstraintX = $0.alignToSuperview(.left, offset: 15.0).first
//            self.frontSpinnerConstraintY = $0.alignToSuperview(.centerY).first
//          }
//        }
//
//        if let endSpinner = endSpinner {
//          if let constraintX = endSpinnerConstraintX { endSpinner.removeConstraint(constraintX) }
//          if let constraintY = endSpinnerConstraintY { endSpinner.removeConstraint(constraintY) }
//
//          endSpinner.autoLayout {
//            self.endSpinnerConstraintX = $0.alignToSuperview(.right, offset: 15.0).first
//            self.endSpinnerConstraintY = $0.alignToSuperview(.centerY).first
//          }
//        }
//      }
//    }
//
//    if check.isDirty(\Foo.isScrollEnabled) {
//      collectionView.isScrollEnabled = isScrollEnabled
//    }
//
//    if check.isDirty(\Foo.showsScrollIndicator) {
//      switch orientation {
//      case .vertical:
//        collectionView.showsVerticalScrollIndicator = showsScrollIndicator
//        collectionView.showsHorizontalScrollIndicator = false
//      default:
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.showsHorizontalScrollIndicator = showsScrollIndicator
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
//    if check.isDirty(\Foo.selectionMode) {
//      switch selectionMode {
//      case .multiple:
//        collectionView.allowsMultipleSelection = true
//        collectionView.allowsSelection = true
//      case .single:
//        // This is enabled for a reason. The native `UICollectionView` behaves
//        // weirdly, such that if `allowsMultipleSelection` is `false`, and a
//        // cell has `collectionView:shouldSelectItemAt:` returning `false`, the
//        // previously selected cell still gets deselected. Hence this custom
//        // controller manually handles single selection restrictions.
//        collectionView.allowsMultipleSelection = true
//        collectionView.allowsSelection = true
//      default:
//        collectionView.allowsMultipleSelection = false
//        collectionView.allowsSelection = true
//      }
//    }
//
//    if check.isDirty(\Foo.selectedDataset, \Foo.selectedData, \Foo.selectedDatum) {
//      if let indexPaths = collectionView.indexPathsForSelectedItems {
//        for indexPath in indexPaths {
//          guard let cell = collectionView.cellForItem(at: indexPath), let datum = datum(at: indexPath) else { continue }
//          cell.isSelected = isDatumSelected(datum)
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
//  /// Specifies whether the collection view will refresh automatically whenever
//  /// the view re/appears.
//  public var shouldAutoReload: Bool = true
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
//  /// Fetches data from data sources for the specified section. Override this
//  /// method to define how data should be fetched from data sources.
//  ///
//  /// - Parameters:
//  ///   - section: The section to fetch data for.
//  ///   - queue: The queue to fetch data in.
//  ///   - completion: Handler invoked upon completion with a `Result` of either
//  ///                 a `.success` value value of the fetched data or a
//  ///                 `.failure` with the error.
//  open func fetchData(for section: Int, queue: DispatchQueue, completion: @escaping (Result<[T], Error>) -> Void) {
//    completion(.success(getDataset()[section] ?? []))
//  }
//
//  /// Fetches data for all sections.
//  ///
//  /// - Parameters:
//  ///   - completion: Handler invoked upon completion with a `Result` as either
//  ///                 a `.success` with the fetched dataset or a `.failure` with
//  ///                 the first encountered error.
//  private func fetchData(completion: @escaping (Result<[Int: [T]], Error>) -> Void) {
//    let group = DispatchGroup()
//
//    var firstEncounteredError: Error? = nil
//    var newDataset: [Int: [T]] = [:]
//
//    for section in 0 ..< numberOfSections {
//      group.enter()
//
//      fetchData(for: section, queue: fetchQueue) { result in
//        switch result {
//        case .failure(let error):
//          if firstEncounteredError == nil {
//            firstEncounteredError = error
//          }
//        case .success(let data):
//          newDataset[section] = data
//        }
//
//        group.leave()
//      }
//    }
//
//    group.notify(queue: fetchQueue) {
//      if let error = firstEncounteredError {
//        completion(.failure(error))
//      }
//      else {
//        completion(.success(newDataset))
//      }
//    }
//  }
//
//  /// Refetches all data, consequently reloading the cells in the collection
//  /// view. If a previous reload is in progress, it will be cancelled.
//  open func reloadData() {
//    delegate?.dataCollectionViewControllerWillReloadData(self)
//
//    // Cancel previous reload if it is in progress.
//    switch dataState {
//    case .loading(from: _): cancelReload()
//    default: break
//    }
//
//    dataState = .loading(from: dataState)
//
//    fetchData { result in
//      DispatchQueue.main.async {
//        switch result {
//        case .failure(let error):
//          self.setDataset([:])
//          self.dataState = .error(error: error)
//        case .success(let dataset):
//          self.setDataset(dataset)
//          self.dataState = self.count() > 0 ? .hasData : .noData
//        }
//
//        // Prior to reloading cells in the collection view, ensure that the
//        // spinners are stopped and their exit animations are complete.
//        self.stopSpinnersIfNeeded {
//          self.reloadCells()
//
//          // Only apply default selection if there are no selected cells at the
//          // moment.
//          if self.indexPathsForSelectedCells.count == 0 {
//            self.applyDefaultSelection()
//          }
//
//          self.dataDidReload()
//        }
//      }
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
//  /// Method that indicates if pull-to-reload is allowed per data state.
//  /// Override this for custom behavior.
//  ///
//  /// - Parameters:
//  ///   - dataState: The data state to check.
//  ///
//  /// - Returns: `true` to allow pull-to-reload, `false` otherwise.
//  open func willPullToReload(in dataState: DataState) -> Bool { false }
//
//  /// Handler invoked when data is reloaded.
//  private func dataDidReload() {
//    delegate?.dataCollectionViewControllerDidReloadData(self)
//  }
//
//  // MARK: - Selection Management
//
//  /// Invalidates the `selectedDataset`, ensuring that it does not contain any
//  /// outdated data not in the current dataset.
//  private func invalidateSelectedDataset() {
//    let currValue = getSelectedDataset()
//    let dataset = getDataset()
//    var newValue: [Int: [T]] = [:]
//
//    for (section, entries) in currValue {
//      guard let data = dataset[section] else { continue }
//
//      newValue[section] = entries.filter({ entry in
//        data.contains { datum in areDataEqual(a: datum, b: entry) }
//      })
//    }
//
//    setSelectedDataset(newValue)
//  }
//
//  /// Applies default cell selection(s). This is invoked upon initial load and subsequent reloads of
//  /// the collection view.
//  private func applyDefaultSelection() {
//    switch selectionMode {
//    case .single:
//      guard let selectedData = delegate?.dataCollectionViewControllerWillApplyDefaultSelection(self) as? T else { return }
//      guard let indexPath = firstIndexPath(for: selectedData) else { return }
//
//      if shouldSelectCellAt(indexPath) {
//        selectCellInCollectionView(at: indexPath, scrollPosition: orientation == .vertical ? .centeredVertically : .centeredHorizontally)
//        enqueueSelectedDatum(at: indexPath)
//      }
//      else {
//        scrollToCell(at: indexPath, animated: false)
//      }
//
//      delegate?.dataCollectionViewControllerDidApplyDefaultSelection(self)
//    case .multiple:
//      guard let selectedData = delegate?.dataCollectionViewControllerWillApplyDefaultSelection(self) as? [T] else { return }
//
//      for data in selectedData {
//        guard let indexPath = firstIndexPath(for: data), shouldSelectCellAt(indexPath) else { continue }
//        selectCellInCollectionView(at: indexPath, scrollPosition: .init(rawValue: 0))
//        enqueueSelectedDatum(at: indexPath)
//      }
//
//      delegate?.dataCollectionViewControllerDidApplyDefaultSelection(self)
//    case .none: return
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
//  open override func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//
//    // Update bounds of the spinners.
//    if let mask = frontSpinnerMask, let spinner = frontSpinner {
//      mask.bounds = spinner.bounds
//      mask.frame = spinner.bounds
//    }
//
//    if let mask = endSpinnerMask, let spinner = endSpinner {
//      mask.bounds = spinner.bounds
//      mask.frame = spinner.bounds
//    }
//  }
//
//  // MARK: - Scrolling
//
//  /// Specifies if scrolling is enabled (relative to the orientation).
//  @Stateful public var isScrollEnabled: Bool = true
//
//  /// Specifies if scroll indicators are visible (relative to the orientation).
//  @Stateful public var showsScrollIndicator: Bool = true
//
//  /// Scrolls to the beginning of the collection.
//  ///
//  /// - Parameters:
//  ///   - animated: Specifies if the scrolling is animated.
//  public func scrollToBeginning(animated: Bool) {
//    collectionView.setContentOffset(collectionView.minContentOffset, animated: animated)
//  }
//
//  /// Scrolls to the end of the collection.
//  ///
//  /// - Parameters:
//  ///   - animated: Specifies if the scrolling is animated.
//  public func scrollToEnd(animated: Bool) {
//    collectionView.setContentOffset(collectionView.maxContentOffset, animated: animated)
//  }
//
//  /// Scrolls to a cell at the specified index path.
//  ///
//  /// - Parameters:
//  ///   - indexPath: The index path of the cell in the collection view.
//  ///   - animated: Specifies if the scrolling is animated.
//  public func scrollToCell(at indexPath: IndexPath, animated: Bool = true) {
//    collectionView.scrollToItem(at: indexPath, at: orientation == .vertical ? .centeredVertically : .centeredHorizontally, animated: animated)
//  }
//
//  /// Scrolls to the first cell with the specified datum.
//  ///
//  /// - Parameters:
//  ///   - datum: The datum of the cell.
//  ///   - animated: Specifies if the scrolling is animated.
//  public func scrollToDatum(_ datum: T, animated: Bool = true) {
//    guard let indexPath = firstIndexPath(for: datum) else { return }
//    scrollToCell(at: indexPath, animated: animated)
//  }
//
//  open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//    layoutSpinnersIfNeeded()
//    delegate?.dataCollectionViewControllerDidScroll(self)
//  }
//
//  open override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//    startSpinnersIfNeeded()
//  }
//
//  // MARK: - Pull-to-Reload Management
//
//  /// Distance required to overscroll in order to trigger a reload (consequently
//  /// showing the spinner). This value INCLUDES the content insets of the
//  /// collection view.
//  public var displacementToTriggerReload: CGFloat = 60.0
//
//  /// Specifies whether user can pull to reload at end of collection (as
//  /// opposed to only the front).
//  public var canPullFromEndToReload: Bool = true
//
//  /// Reload control spinner at the front of the collection view.
//  public var frontSpinner: DataCollectionViewSpinner? {
//    willSet {
//      if let oldSpinner = frontSpinner {
//        oldSpinner.removeFromSuperview()
//        frontSpinnerMask = nil
//      }
//    }
//
//    didSet {
//      if let backgroundView = collectionView.backgroundView, let newSpinner = frontSpinner {
//        backgroundView.addSubview(newSpinner)
//
//        let mask = CAGradientLayer()
//        mask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
//        // HACK: Use -0.01 here because somehow when the start and end points
//        // are identical, the layer mask doesn't work at all.
//        mask.startPoint = CGPoint(x: -0.01, y: 0.5)
//        mask.endPoint = CGPoint(x: 0.0, y: 0.5)
//        newSpinner.layer.mask = mask
//        frontSpinnerMask = mask
//
//        stateMachine.invalidate(\Foo.frontSpinner)
//      }
//    }
//  }
//
//  /// Gradient mask of the reload control spinner at the end of the collection
//  /// view.
//  private var frontSpinnerMask: CAGradientLayer?
//
//  /// X constraint of the front spinner.
//  private var frontSpinnerConstraintX: NSLayoutConstraint?
//
//  /// Y constraint of the front spinner.
//  private var frontSpinnerConstraintY: NSLayoutConstraint?
//
//  /// Reload control spinner at the end of the collection view.
//  public var endSpinner: DataCollectionViewSpinner? {
//    willSet {
//      if let oldSpinner = endSpinner {
//        oldSpinner.removeFromSuperview()
//        endSpinnerMask = nil
//      }
//    }
//
//    didSet {
//      if let backgroundView = collectionView.backgroundView, let newSpinner = endSpinner {
//        backgroundView.addSubview(newSpinner)
//
//        let mask = CAGradientLayer()
//        mask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
//        mask.startPoint = CGPoint(x: 1.01, y: 0.5)
//        mask.endPoint = CGPoint(x: 1.0, y: 0.5)
//        newSpinner.layer.mask = mask
//
//        endSpinnerMask = mask
//
//        stateMachine.invalidate(\Foo.endSpinner)
//      }
//    }
//  }
//
//  /// Gradient mask of the reload control spinner at the end of the collection
//  /// view.
//  private var endSpinnerMask: CAGradientLayer?
//
//  /// X constraint of the end spinner.
//  private var endSpinnerConstraintX: NSLayoutConstraint?
//
//  /// Y constraint of the end spinner.
//  private var endSpinnerConstraintY: NSLayoutConstraint?
//
//  /// Starts either the front or the end spinners if applicable, depending on
//  /// the current scroll position of the collection view.
//  private func startSpinnersIfNeeded() {
//    guard willPullToReload(in: dataState) else { return }
//
//    var frontDelta: CGFloat = 0.0
//    var endDelta: CGFloat = 0.0
//
//    switch orientation {
//    case .vertical:
//      frontDelta = min(0.0, collectionView.contentOffset.y - collectionView.minContentOffset.y)
//      endDelta = max(0.0, collectionView.contentOffset.y - collectionView.maxContentOffset.y)
//    default:
//      frontDelta = min(0.0, collectionView.contentOffset.x - collectionView.minContentOffset.x)
//      endDelta = max(0.0, collectionView.contentOffset.x - collectionView.maxContentOffset.x)
//    }
//
//    if frontDelta < -displacementToTriggerReload {
//      startFrontSpinner()
//    }
//    else if canPullFromEndToReload, endDelta > displacementToTriggerReload {
//      startEndSpinner()
//    }
//  }
//
//  /// Stops all active spinners.
//  ///
//  /// - Parameters:
//  ///   - completion: Handler invoked upon completion.
//  private func stopSpinnersIfNeeded(completion: @escaping () -> Void = {}) {
//    let group = DispatchGroup()
//
//    group.enter()
//    group.enter()
//
//    stopFrontSpinner() { group.leave() }
//    stopEndSpinner() { group.leave() }
//
//    group.notify(queue: .main) {
//      completion()
//    }
//  }
//
//  /// Starts the reload control spinner at the front of the collection.
//  private func startFrontSpinner() {
//    guard
//      let frontSpinner = frontSpinner,
//      !frontSpinner.isActive,
//      endSpinner?.isActive != true,
//      willPullToReload(in: dataState)
//    else { return }
//
//    frontSpinner.isActive = true
//    frontSpinnerMask?.endPoint = CGPoint(x: 2.0, y: 0.5)
//
//    var insets = contentInsets
//
//    switch orientation {
//    case .vertical: insets.top = displacementToTriggerReload
//    default: insets.left = displacementToTriggerReload
//    }
//
//    // Reload is triggered when the user pulls from the front of the scroll
//    // view. When the pull is released, animate the scroll view position so it
//    // is parked just beside the front spinner.
//    DispatchQueue.main.async {
//      UIView.animate(withDuration: 0.2, animations: {
//        self.collectionView.contentInset = insets
//      }, completion: nil)
//
//      var offset = self.collectionView.contentOffset
//
//      switch self.orientation {
//      case .vertical:
//        offset.y = self.collectionView.minContentOffset.y
//      default:
//        offset.x = self.collectionView.minContentOffset.x
//      }
//
//      self.collectionView.setContentOffset(offset, animated: true)
//    }
//
//    reloadData()
//  }
//
//  /// Stops the reload control spinner at the front of the collection view.
//  ///
//  /// - Parameters:
//  ///   - completion: Handle invoked upon completion.
//  private func stopFrontSpinner(completion: (() -> Void)? = nil) {
//    guard let frontSpinner = frontSpinner, frontSpinner.isActive else {
//      completion?()
//      return
//    }
//
//    frontSpinner.isActive = false
//    frontSpinnerMask?.endPoint = CGPoint(x: 0.0, y: 0.5)
//
//    // Play collapsing animation in the next UI cycle to avoid choppiness.
//    DispatchQueue.main.async {
//      UIView.animate(withDuration: 0.2, animations: {
//        self.collectionView.contentInset = self.contentInsets
//      }) { _ in
//        completion?()
//      }
//    }
//  }
//
//  /// Starts the reload control spinner at the end of the collection.
//  private func startEndSpinner() {
//    guard
//      let endSpinner = endSpinner,
//      !endSpinner.isActive,
//      frontSpinner?.isActive != true,
//      canPullFromEndToReload,
//      willPullToReload(in: dataState)
//    else { return }
//
//    endSpinner.isActive = true
//    endSpinnerMask?.endPoint = CGPoint(x: -1.0, y: 0.5)
//
//    var insets = contentInsets
//
//    switch orientation {
//    case .vertical: insets.bottom = displacementToTriggerReload
//    default: insets.right = displacementToTriggerReload
//    }
//
//    // Reload is triggered when the user pulls from the end of the scroll view.
//    // When the pull is released, animate the scroll view position so it is
//    // parked just beside the end spinner.
//    DispatchQueue.main.async {
//      UIView.animate(withDuration: 0.2, animations: {
//        self.collectionView.contentInset = insets
//      }, completion: nil)
//
//      var offset = self.collectionView.contentOffset
//
//      switch self.orientation {
//      case .vertical:
//        offset.y = self.collectionView.maxContentOffset.y
//      default:
//        offset.x = self.collectionView.maxContentOffset.x
//      }
//
//      self.collectionView.setContentOffset(offset, animated: true)
//    }
//
//    reloadData()
//  }
//
//  /// Stops the reload control spinner at the end of the collection view.
//  ///
//  /// - Parameters:
//  ///   - completion: Handle invoked upon completion.
//  private func stopEndSpinner(completion: (() -> Void)? = nil) {
//    guard let endSpinner = endSpinner, endSpinner.isActive else {
//      completion?()
//      return
//    }
//
//    endSpinner.isActive = false
//    endSpinnerMask?.endPoint = CGPoint(x: 1.0, y: 0.5)
//
//    // Play collapsing animation in the next UI cycle to avoid choppiness.
//    DispatchQueue.main.async {
//      UIView.animate(withDuration: 0.2, animations: {
//        self.collectionView.contentInset = self.contentInsets
//      }) { _ in
//        completion?()
//      }
//    }
//  }
//
//  /// Update layout of spinners if needed.
//  private func layoutSpinnersIfNeeded() {
//    guard willPullToReload(in: dataState) else { return }
//
//    switch orientation {
//    case .vertical:
//      // Content offset of scrollview should be < 0
//      let frontDelta: CGFloat = min(0.0, collectionView.contentOffset.y - collectionView.minContentOffset.y)
//      frontSpinnerMask?.endPoint = CGPoint(x: min(1.0, abs(frontDelta / displacementToTriggerReload)) * 2.0, y: 0.5)
//
//      if canPullFromEndToReload {
//        // Content offset of scrollview should be > 0
//        let endDelta: CGFloat = max(0.0, collectionView.contentOffset.y - collectionView.maxContentOffset.y)
//        endSpinnerMask?.endPoint = CGPoint(x: 1.0 - min(1.0, abs(endDelta / displacementToTriggerReload)) * 2.0, y: 0.5)
//      }
//    default:
//      // Content offset of scrollview should be < 0
//      let frontDelta: CGFloat = min(0.0, collectionView.contentOffset.x - collectionView.minContentOffset.x)
//      frontSpinnerMask?.endPoint = CGPoint(x: min(1.0, abs(frontDelta / displacementToTriggerReload)) * 2.0, y: 0.5)
//
//      if canPullFromEndToReload {
//        // Content offset of scrollview should be > 0
//        let endDelta: CGFloat = max(0.0, collectionView.contentOffset.x - collectionView.maxContentOffset.x)
//        endSpinnerMask?.endPoint = CGPoint(x: 1.0 - min(1.0, abs(endDelta / displacementToTriggerReload)) * 2.0, y: 0.5)
//      }
//    }
//  }
//}
