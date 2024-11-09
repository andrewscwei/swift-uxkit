import BaseKit
import UIKit

/// A custom `UIViewController` that manages a `UICollectionView` whose items
/// are derived from a `UICollectionViewDiffableDataSource`. Since items are
/// expected to be diffable, their values must be unique across sections even if
/// they are the same type.
open class CollectionViewController<S: Hashable & CaseIterable, I: Hashable>: UIViewController, UICollectionViewDelegate, StateMachineDelegate {

  // MARK: - Delegation

  public weak var delegate: (any CollectionViewControllerDelegate)?

  private lazy var itemSelectionDelegate = CollectionViewItemSelectionDelegate<S, I>(
    collectionView: collectionView,
    selectionDidChange: { self.selectionDidChange() },
    shouldSelectItem: { self.shouldSelectItem(item: $0, section: $1) },
    shouldDeselectItem: { self.shouldDeselectItem(item: $0, section: $1) }
  )

  private lazy var scrollDelegate = CollectionViewScrollDelegate<S, I>(
    collectionView: collectionView
  )

  private lazy var refreshControlDelegate = CollectionViewRefreshControlDelegate(
    collectionView: collectionView,
    frontRefreshControl: delegate?.collectionFrontRefreshControl(self) ?? frontRefreshControlFactory(),
    endRefreshControl: delegate?.collectionEndRefreshControl(self) ?? endRefreshControlFactory(),
    willPullToRefresh: { self.willPullToRefresh() },
    didPullToRefresh: { self.didPullToRefresh() }
  )

  private lazy var filterDelegate = CollectionViewFilterDelegate<S, I>(
    collectionView: collectionView,
    filterPredicate: { item, query in self.delegate?.collection(self, shouldIncludeItem: item, withFilterQuery: query) ?? true },
    filteredDataSetDidChange: { self.filteredDataSetDidChange() }
  )

  // MARK: - Subviews

  public lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

  public var frontRefreshControl: CollectionViewRefreshControl? { refreshControlDelegate.frontRefreshControl }

  public var endRefreshControl: CollectionViewRefreshControl? { refreshControlDelegate.endRefreshControl }

  // MARK: - States

  public lazy var stateMachine = StateMachine(self)

  /// Data set of which the collection view data source is derived from.
  ///
  /// Any changes made to this data set is immediately applied to the current
  /// data source snapshot, thus refreshing the items in the collection view.
  ///  Though not explicitly enforced, there should be no duplicate items within
  /// the same section (same item across multiple sections is OK).
  @Stateful private var dataSet: [S: [I]] = [:]

  // MARK: - Properties

  /// The data source object.
  public lazy var dataSource: UICollectionViewDiffableDataSource<S, I> = dataSourceFactory()

  /// The currently selected items.
  public var selectedItems: [I] {
    get { itemSelectionDelegate.getSelectedItems() }
    set { itemSelectionDelegate.setSelectedItems(newValue) }
  }

  /// The currently selected item.
  public var selectedItem: I? {
    get { itemSelectionDelegate.getSelectedItems().first }
    set { itemSelectionDelegate.setSelectedItems(newValue.map { [$0] } ?? []) }
  }

  /// Specifies how the collection view selects its cells.
  public var selectionMode: CollectionViewSelectionMode {
    get { itemSelectionDelegate.selectionMode }
    set { itemSelectionDelegate.selectionMode = newValue }
  }

  /// Specifies if scrolling is enabled.
  public var isScrollEnabled: Bool {
    get { scrollDelegate.isScrollEnabled }
    set { scrollDelegate.isScrollEnabled = newValue }
  }

  /// Specifies if scroll indicators are visible.
  public var showsScrollIndicator: Bool {
    get { scrollDelegate.showsScrollIndicator }
    set { scrollDelegate.showsScrollIndicator = newValue }
  }

  /// Distance required to overscroll in order to trigger a refresh
  /// (consequently showing the refresh control). This value INCLUDES the
  /// content insets of the collection view.
  public var displacementToTriggerRefresh: CGFloat {
    get { refreshControlDelegate.displacementToTriggerRefresh }
    set { refreshControlDelegate.displacementToTriggerRefresh = newValue }
  }

  /// Specifies the orientation of the refresh controls.
  public var refreshControlOrientation: UICollectionView.ScrollDirection {
    get { refreshControlDelegate.orientation }
    set { refreshControlDelegate.orientation = newValue }
  }

  /// Specifies the filter query.
  public var filterQuery: Any? {
    get { filterDelegate.query }
    set { filterDelegate.query = newValue }
  }

  /// The content insets of the collection view.
  public var contentInsets: UIEdgeInsets {
    get { refreshControlDelegate.contentInsets }
    set { refreshControlDelegate.contentInsets = newValue }
  }

  /// List of handlers to invoke after scroll animation.
  private var endScrollingAnimationHandlers: [() -> Void] = []

  // MARK: - Life Cycle

  open override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.backgroundColor = .clear
    collectionView.bounces = true
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.dataSource = dataSource
    collectionView.delaysContentTouches = false
    collectionView.delegate = self

    loadSubviews()
  }

  /// Adds and configures all subviews in view and defines auto layout
  /// constraints.
  ///
  /// This method by default sets the auto layout constraints of the internal
  /// collection view. Override this method without calling `super` to provide
  /// your own constraints.
  open func loadSubviews() {
    view.addSubview(collectionView)
    collectionView.autoLayout { $0.alignToSuperview() }
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    stateMachine.start()
    itemSelectionDelegate.stateMachine.start()
    scrollDelegate.stateMachine.start()
    refreshControlDelegate.stateMachine.start()
    filterDelegate.stateMachine.start()
  }

  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    filterDelegate.stateMachine.stop()
    refreshControlDelegate.stateMachine.stop()
    scrollDelegate.stateMachine.stop()
    itemSelectionDelegate.stateMachine.stop()
    stateMachine.stop()
  }

  // MARK: - Data Management

  /// Sets the data set, consequently updating the data source snapshot.
  ///
  /// - Parameters:
  ///   - dataSet: Data set.
  ///   - animated: Specifies if the update should be animated.
  public func setDataSet(_ dataSet: [S: [I]], animated: Bool = true) {
    self.dataSet = dataSet
    updateSnapshot(with: dataSet, animated: animated)
  }

  private func dataSourceFactory() -> UICollectionViewDiffableDataSource<S, I> {
    let dataSource = UICollectionViewDiffableDataSource<S, I>(collectionView: collectionView) { collectionView, indexPath, item in
      let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
      let cell = self.delegate?.collection(self, cellAtIndexPath: indexPath, section: section, item: item) ?? self.cellFactory(at: indexPath, section: section, item: item)
      self.invalidateCell(cell, at: indexPath, section: section, item: item)
      return cell
    }

    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      if let view = self.delegate?.collection(self, supplementaryViewAtIndexPath: indexPath, kind: kind) ?? self.supplementaryViewFactory(at: indexPath, kind: kind) {
        self.invalidateSupplementaryView(view, at: indexPath, kind: kind)
        return view
      }
      else {
        return nil
      }
    }

    return dataSource
  }

  private func updateSnapshot(with dataSet: [S: [I]], animated: Bool) {
    var snapshot = NSDiffableDataSourceSnapshot<S, I>()

    let oldItems = dataSource.snapshot().itemIdentifiers
    let newItems = dataSet.reduce([I]()) { $0 + $1.value }
    let itemsToReconfigure = Array(Set(oldItems).intersection(Set(newItems)))
    let sectionsToAppend = S.allCases.reduce([S]()) { (dataSet[$1] ?? []).count > 0 ? $0 + [$1] : $0 }

    snapshot.appendSections(sectionsToAppend)

    for section in sectionsToAppend {
      snapshot.appendItems(dataSet[section] ?? [], toSection: section)
    }

    snapshot.reconfigureItems(itemsToReconfigure)

    dataSource.apply(snapshot, animatingDifferences: animated)

    itemSelectionDelegate.invalidateSelectedIndexPaths()
  }

  // MARK: - Cell Management

  /// Factory for cells in the collection view.
  ///
  /// Cells are resolved from the first non-nil result of the following methods,
  /// ordered by priority:
  ///   1. From a `CollectionViewControllerDelegate` implementing
  ///      `collection(_:cellAtIndexPath:section:item:)`.
  ///   2. From a subclass overriding this `cellFactory(at:section:item:)`.
  ///
  /// It is recommended for cells to be dequeued and reused, such as by using
  /// `dequeueConfiguredReusableCell(using:for:item:)`.
  /// `
  /// - Parameters:
  ///   - indexPath: Index path.
  ///   - section: Section.
  ///   - item: Item.
  /// - Returns: The `UICollectionViewCell`.
  open func cellFactory(at indexPath: IndexPath, section: S, item: I) -> UICollectionViewCell {
    fatalError("CollectionViewController requires cells to be provided by either a CollectionViewControllerDelegate implementing collection(_:cellAtIndexPath:section:item:) or a subclass overriding cellFactory(at:section:item:)")
  }

  // MARK: - Supplementary Views Management

  /// Factory for supplementary views in the collection view.
  ///
  /// Supplementary views are resolved from the first non-nil result of the
  /// following methods, ordered by priority:
  ///   1. From a `CollectionViewControllerDelegate` implementing
  ///      `collection(_:supplementaryViewAtIndexPath:kind:)`.
  ///   2. From a subclass overriding this `supplementaryViewFactory(at:kind:)`.
  ///
  /// It is recommended for cells to be dequeued and reused, such as by using
  /// `dequeueConfiguredReusableSupplementary(using:for:)`.
  /// `
  /// - Parameters:
  ///   - indexPath: Index path.
  ///   - section: Section.
  ///   - item: Item.
  /// - Returns: The `UICollectionReusableView`.
  open func supplementaryViewFactory(at indexPath: IndexPath, kind: String) -> UICollectionReusableView? {
    nil
  }

  // MARK: - Selection Management

  public func isItemSelected(_ item: I, where predicate: (I, I) -> Bool = { $0 == $1 }) -> Bool {
    itemSelectionDelegate.isItemSelected(item, where: predicate)
  }

  public func areAllItemsSelected(in section: S, where predicate: (I, I) -> Bool = { $0 == $1 }) -> Bool {
    itemSelectionDelegate.areAllItemsSelected(in: section, where: predicate)
  }

  public func areAllItemsDeselected(in section: S, where predicate: (I, I) -> Bool = { $0 == $1 }) -> Bool {
    itemSelectionDelegate.areAllItemsDeselected(in: section, where: predicate)
  }

  public func hasSection(_ section: S) -> Bool {
    let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers
    return sectionIdentifiers.contains(section)
  }

  public func getSection(at sectionIndex: Int) -> S? {
    let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers
    guard sectionIndex < sectionIdentifiers.count else { return nil }
    return sectionIdentifiers[sectionIndex]
  }

  public func getIndex(for section: S) -> Int? {
    return dataSource.snapshot().indexOfSection(section)
  }

  public func hasItem(_ item: I) -> Bool {
    let itemIdentifiers = dataSource.snapshot().itemIdentifiers
    return itemIdentifiers.contains(item)
  }

  public func getItem(at indexPath: IndexPath) -> I? { itemSelectionDelegate.mapIndexPathToItem(indexPath) }

  public func getIndexPath(for item: I) -> IndexPath? { itemSelectionDelegate.mapItemToIndexPath(item) }

  @discardableResult
  public func selectItem(_ item: I) -> I? {
    guard let item = itemSelectionDelegate.selectItem(item, where: { $0 == $1 }) else { return nil }

    return item
  }

  @discardableResult
  public func selectAllItems(in section: S) -> [I] {
    itemSelectionDelegate.selectAllItems(in: section, where: { $0 == $1 })
  }

  @discardableResult
  public func deselectItem(_ item: I) -> I? {
    itemSelectionDelegate.deselectItem(item, where: { $0 == $1 })
  }

  @discardableResult
  public func deselectAllItems(in section: S? = nil) -> [I] {
    if let section = section {
      return itemSelectionDelegate.deselectAllItems(in: section, where: { $0 == $1 })
    }
    else {
      var deselectedItems: [I] = []

      for section in dataSource.snapshot().sectionIdentifiers {
        deselectedItems += itemSelectionDelegate.deselectAllItems(in: section, where: { $0 == $1 })
      }

      return deselectedItems
    }
  }

  private func selectionDidChange() {
    stateMachine.invalidate(\CollectionViewController.selectedItem, \CollectionViewController.selectedItems)
    delegate?.collectionSelectionDidChange(self)
  }

  private func shouldSelectItem(item: I, section: S) -> Bool {
    delegate?.collection(self, shouldSelectItem: item, in: section) ?? true
  }

  private func shouldDeselectItem(item: I, section: S) -> Bool {
    delegate?.collection(self, shouldDeselectItem: item, in: section) ?? true
  }

  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if let item = getItem(at: indexPath), let section = getSection(at: indexPath.section) {
      delegate?.collection(self, didTapOnItem: item, in: section)
    }

    return itemSelectionDelegate.shouldSelectItem(at: indexPath)
  }

  public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    itemSelectionDelegate.shouldDeselectItem(at: indexPath)
  }

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    itemSelectionDelegate.selectItem(at: indexPath, where: { $0 == $1 })
  }

  public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    itemSelectionDelegate.deselectItem(at: indexPath, where: { $0 == $1 })
  }

  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}

  // MARK: - Scroll Management

  /// Scrolls to the beginning of the collection view.
  ///
  /// - Parameters:
  ///   - animated: Specifies if scrolling is animated.
  ///   - completionHandler: Handler invoked when scrolling is complete.
  open func scrollToBeginning(animated: Bool = true, completion completionHandler: (() -> Void)? = nil) {
    if let handler = completionHandler {
      endScrollingAnimationHandlers.append(handler)
    }

    scrollDelegate.scrollToBeginning(animated: animated)
  }

  /// Scrolls to the beginning of the collection view.
  ///
  /// - Parameters:
  ///   - animated: Specifies if scrolling is animated.
  ///   - completionHandler: Handler invoked when scrolling is complete.
  open func scrollToEnd(animated: Bool = true, completion completionHandler: (() -> Void)? = nil) {
    if let handler = completionHandler {
      endScrollingAnimationHandlers.append(handler)
    }

    scrollDelegate.scrollToEnd(animated: animated)
  }

  /// Scrolls to an item.
  ///
  /// - Parameters:
  ///   - item: Item.
  ///   - animated: Specifies if scrolling behavior is animated.
  ///   - completionHandler: Handler invoked when scrolling is complete.
  open func scrollToItem(_ item: I, animated: Bool = true, completion completionHandler: (() -> Void)? = nil) {
    guard hasItem(item) else { return }

    if let handler = completionHandler {
      endScrollingAnimationHandlers.append(handler)
    }

    scrollDelegate.scrollToItem(item, animated: animated)
  }

  /// Handler invoked when the collection view begins dragging.
  open func willBeginDragging() {}

  /// Handler invoked when the collection view ends dragging.
  ///
  /// - Parameter decelerate: Indicates if the collection view is decelerating
  ///                         its scrolling after dragging ended.
  open func didEndDragging(willDecelerate decelerate: Bool) {}

  /// Handler invoked when scroll deceleration ends.
  open func didEndDeceleratingFromDragging() {}

  /// Handler invoked when the collection view scrolls.
  open func didScroll() {}

  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    willBeginDragging()
    delegate?.collectioWillBeginDragging(self)
  }

  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    didEndDragging(willDecelerate: decelerate)
    delegate?.collectionDidEndDragging(self, willDecelerate: decelerate)
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    didEndDeceleratingFromDragging()
    delegate?.collectionDidEndDeceleratingFromDragging(self)
  }

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    refreshControlDelegate.layoutRefreshControlsIfNeeded()

    didScroll()
    delegate?.collectionDidScroll(self)
  }

  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    for handler in endScrollingAnimationHandlers {
      handler()
    }

    endScrollingAnimationHandlers = []
  }

  // MARK: - Pull-to-Refresh Management

  /// Factory for the front refresh control. Return `nil` to indicate the
  /// absence of a front refresh control.
  ///
  /// The front refresh control is resolved from the first non-nil result of the
  /// following methods, ordered by priority:
  ///   1. From a `CollectionViewControllerDelegate` implementing
  ///      `collectionFrontRefreshControl(_:).
  ///   2. From a subclass overriding `frontRefreshControlFactory()`.
  ///
  /// - Returns: The `CollectionViewRefreshControl` if applicable.
  open func frontRefreshControlFactory() -> CollectionViewRefreshControl? {
    nil
  }

  /// Factory for the end refresh control. Return `nil` to indicate the absence
  /// of an end refresh control.
  ///
  /// The end refresh control is resolved from the first non-nil result of the
  /// following methods, ordered by priority:
  ///   1. From a `CollectionViewControllerDelegate` implementing
  ///      `collectionEndRefreshControl(_:).
  ///   2. From a subclass overriding `endRefreshControlFactory()`.
  ///
  /// - Returns: The `CollectionViewRefreshControl` if applicable.
  open func endRefreshControlFactory() -> CollectionViewRefreshControl? {
    nil
  }

  private func willPullToRefresh() -> Bool {
    delegate?.collectionWillPullToRefresh(self) ?? true
  }

  private func didPullToRefresh() {
    collectionView.isScrollEnabled = false
    delegate?.collectionDidPullToRefresh(self)
  }

  public func notifyRefreshComplete(completion: @escaping () -> Void = {}) {
    collectionView.isScrollEnabled = isScrollEnabled
    refreshControlDelegate.deactivateRefreshControlsIfNeeded(completion: completion)
  }

  public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    refreshControlDelegate.activateRefreshControlsIfNeeded()
  }

  // MARK: - Filter Management

  private func filteredDataSetDidChange() {
    updateSnapshot(with: filterDelegate.filteredDataSet, animated: true)
  }

  // MARK: - Layout

  /// Factory for the collection view layout.
  ///
  /// Collection view layout is resolved from the first non-nil result of the
  /// following methods, ordered by priority:
  ///   1. From a `CollectionViewControllerDelegate` implementing
  ///      `collectionViewLayout(_:)`.
  ///   2. From a subclass overriding `layoutFactory()`.
  ///
  /// - Returns: The `UICollectionViewLayout`.
  open func layoutFactory() -> UICollectionViewLayout {
    _log.error { "Creating collection view layout... WARN\n↘︎ No collection view layout provided, please override layoutFactory() or implement the delegate method collectionViewLayout(_:)" }

    return UICollectionViewLayout()
  }

  // MARK: - Updating

  open func update(check: StateValidator) {
    if check.isDirty(\UICollectionView.collectionViewLayout) {
      collectionView.setCollectionViewLayout(delegate?.collectionViewLayout(self) ?? layoutFactory(), animated: hasViewAppeared)
    }

    if check.isDirty(\CollectionViewController.dataSet) {
      itemSelectionDelegate.dataSet = dataSet
      filterDelegate.dataSet = dataSet
    }
  }

  /// Reconfigures visible items in the collection view.
  ///
  /// - Parameters:
  ///   - animated: Specifies if the reconfiguration of the visible items is
  ///               animated.
  public func invalidateVisibleItems(animated: Bool = true) {
    let visibleIndexPaths = collectionView.indexPathsForVisibleItems
    let visibleItems = visibleIndexPaths.compactMap { getItem(at: $0) }

    var snapshot = dataSource.snapshot()
    snapshot.reconfigureItems(visibleItems)
    dataSource.apply(snapshot, animatingDifferences: animated)
  }

  /// Executes a block on each cell currently visible in the collection view.
  ///
  /// - Parameters:
  ///   - update: The update block.
  public func updateVisibleCells(update: (UICollectionViewCell, IndexPath, S, I) -> Void) {
    for cell in collectionView.visibleCells {
      guard let indexPath = collectionView.indexPath(for: cell), let item = getItem(at: indexPath), let section = getSection(at: indexPath.section) else { continue }
      update(cell, indexPath, section, item)
    }
  }

  /// Executes a block on each supplementary view currently visible in the
  /// collection view.
  ///
  /// - Parameters:
  ///   - kind: Kind
  ///   - update: The update block.
  public func updateVisibleSupplementaryViews(ofKind kind: String, update: (UICollectionReusableView, IndexPath, String) -> Void) {
    for indexPath in collectionView.indexPathsForVisibleSupplementaryElements(ofKind: kind) {
      guard let view = collectionView.supplementaryView(forElementKind: kind, at: indexPath) else { continue }
      update(view, indexPath, kind)
    }
  }

  /// Invalidates the cell at the given index path, section and item. This is
  /// automatically invoked whenever a cell is created or reused.
  ///
  /// Override this method to configure a cell whenever it is invalidated.
  ///
  /// - Parameters:
  ///   - cell: Cell.
  ///   - indexPath: Index path.
  ///   - section: Section.
  ///   - item: Item.
  open func invalidateCell(_ cell: UICollectionViewCell, at indexPath: IndexPath, section: S, item: I) {

  }

  /// Invalidates all visible supplementary views.
  ///
  /// - Parameters:
  ///   - kind: Kind.
  public func invalidateVisibleSupplementaryViews(ofKind kind: String) {
    updateVisibleSupplementaryViews(ofKind: kind) { self.invalidateSupplementaryView($0, at: $1, kind: $2) }
  }

  /// Invalidates the supplementary view at the given index path and kind. This
  /// is automatically invoked whenever a supplementary view is created or
  /// reused.
  ///
  /// Override this method to configure a supplementary view whenever it is
  /// invalidated.
  ///
  /// - Parameters:
  ///   - view: Supplementary view.
  ///   - indexPath: Index path.
  ///   - kind: Kind.
  open func invalidateSupplementaryView(_ view: UICollectionReusableView, at indexPath: IndexPath, kind: String) {

  }

  /// Invalidates the collection view layout, reapplying it to the collection
  /// view again.
  public func invalidateLayout() {
    stateMachine.invalidate(\UICollectionView.collectionViewLayout)
  }
}
