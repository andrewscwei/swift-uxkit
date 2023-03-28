// © GHOZT

import BaseKit
import UIKit

/// A custom `UIViewController` that manages a `UICollectionView` whose items
/// are derived from a `UICollectionViewDiffableDataSource`. Since items are
/// expected to be diffable, their values must be unique across sections even if
/// they are the same type.
open class CollectionViewController<S: Hashable & CaseIterable, I: Hashable>: UIViewController, UICollectionViewDelegate, StateMachineDelegate {

  // MARK: - Delegation

  public weak var delegate: (any CollectionViewControllerDelegate<S, I>)?

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
    frontRefreshControl: self.delegate?.collectionViewControllerFrontRefreshControl(self),
    endRefreshControl: self.delegate?.collectionViewControllerEndRefreshControl(self),
    willPullToRefresh: { self.willPullToRefresh() },
    didPullToRefresh: { self.didPullToRefresh() }
  )

  private lazy var filterDelegate = CollectionViewFilterDelegate<S, I>(
    collectionView: collectionView,
    filterPredicate: { item, query in self.delegate?.collectionViewController(self, shouldIncludeItem: item, withFilterQuery: query) ?? true },
    filteredDataSetDidChange: { self.filteredDataSetDidChange() }
  )

  // MARK: - Layout

  public lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

  public var frontRefreshControl: (any CollectionViewRefreshControl)? { refreshControlDelegate.frontRefreshControl }

  public var endRefreshControl: (any CollectionViewRefreshControl)? { refreshControlDelegate.endRefreshControl }

  // MARK: - States

  public lazy var stateMachine = StateMachine(self)

  /// Data set of which the collection view data source is derived from.
  ///
  /// Any changes made to this data set is immediately applied to the current
  /// data source snapshot, thus refreshing the items in the collection view.
  ///  Though not explicitly enforced, there should be no duplicate items within
  /// the same section (same item across multiple sections is OK).
  ///
  /// TODO: Enforce no duplicate items in each section.
  @Stateful public var dataSet: [S: [I]] = S.allCases.reduce([:]) { $0.merging([$1: []]) { $1 } }

  // MARK: - Properties

  /// The data source object.
  private lazy var dataSource: UICollectionViewDiffableDataSource<S, I> = dataSourceFactory()

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

  /// Specifies if scroling is enabled.
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

  /// Adds and configures all subviews in view and defines autolayout
  /// constraints.
  ///
  /// This method by default sets the autolayout constraints of the internal
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

  private func dataSourceFactory() -> UICollectionViewDiffableDataSource<S, I> {
    let dataSource = UICollectionViewDiffableDataSource<S, I>(collectionView: collectionView) { collectionView, indexPath, item in
      let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
      let cell = self.cellFactory(at: indexPath, section: section, item: item)
      self.configureCell(cell, at: indexPath, section: section, item: item)
      return cell
    }

    return dataSource
  }

  /// Updates the current snapshot of the data source with a data set.
  ///
  /// - Parameter dataSet: The data set.
  private func updateSnapshot(with dataSet: [S: [I]]) {
    var snapshot = NSDiffableDataSourceSnapshot<S, I>()

    let sectionsToAppend = S.allCases.reduce([S]()) { (dataSet[$1] ?? []).count > 0 ? $0 + [$1] : $0 }

    snapshot.appendSections(sectionsToAppend)

    for section in sectionsToAppend {
      snapshot.appendItems(dataSet[section] ?? [], toSection: section)
    }

    dataSource.apply(snapshot)

    itemSelectionDelegate.invalidateSelectedIndexPaths()
  }

  // MARK: - Cell Management

  private func cellFactory(at indexPath: IndexPath, section: S, item: I) -> UICollectionViewCell {
    guard let cell = delegate?.collectionViewController(self, cellAtIndexPath: indexPath, section: section, item: item) else {
      fatalError("CollectionViewController requires a CollectionViewControllerDelegate to implement collectionViewController(_:cellAtIndexPath:section:item:).")
    }

    return cell
  }

  /// Configures the cell at the given index path, section and item. This is
  /// invoked whenever a cell is being configured (i.e. during cell factory).
  ///
  /// - Parameters:
  ///   - cell: Cell.
  ///   - indexPath: Index path.
  ///   - section: Section.
  ///   - item: Item.
  open func configureCell(_ cell: UICollectionViewCell, at indexPath: IndexPath, section: S, item: I) {

  }

  // MARK: - Selection Management

  public func isItemSelected(_ item: I, where predicate: (I, I) -> Bool = { $0.isEqual(to: $1) }) -> Bool {
    itemSelectionDelegate.isItemSelected(item, where: predicate)
  }

  public func areAllItemsSelected(in section: S, where predicate: (I, I) -> Bool = { $0.isEqual(to: $1) }) -> Bool {
    itemSelectionDelegate.areAllItemsSelected(in: section, where: predicate)
  }

  public func areAllItemsDeselected(in section: S, where predicate: (I, I) -> Bool = { $0.isEqual(to: $1) }) -> Bool {
    itemSelectionDelegate.areAllItemsDeselected(in: section, where: predicate)
  }

  public func getItem(at indexPath: IndexPath) -> I? { itemSelectionDelegate.mapIndexPathToItem(indexPath) }

  public func getIndexPath(for item: I) -> IndexPath? { itemSelectionDelegate.mapItemToIndexPath(item) }

  @discardableResult public func selectItem(_ item: I, shouldScroll: Bool = true, animated: Bool = true) -> I? {
    guard let item = itemSelectionDelegate.selectItem(item, where: { $0.isEqual(to: $1) }) else { return nil }

    if shouldScroll {
      scrollToItem(item, animated: animated)
    }

    return item
  }

  @discardableResult public func selectAllItems(in section: S) -> [I] {
    itemSelectionDelegate.selectAllItems(in: section, where: { $0.isEqual(to: $1) })
  }

  @discardableResult public func deselectItem(_ item: I) -> I? {
    itemSelectionDelegate.deselectItem(item, where: { $0.isEqual(to: $1) })
  }

  @discardableResult public func deselectAllItems(in section: S) -> [I] {
    itemSelectionDelegate.deselectAllItems(in: section, where: { $0.isEqual(to: $1) })
  }

  private func selectionDidChange() {
    stateMachine.invalidate(\CollectionViewController.selectedItem, \CollectionViewController.selectedItems)
    delegate?.collectionViewControllerSelectionDidChange(self)
  }

  private func shouldSelectItem(item: I, section: S) -> Bool {
    delegate?.collectionViewController(self, shouldSelectItem: item, in: section) ?? true
  }

  private func shouldDeselectItem(item: I, section: S) -> Bool {
    delegate?.collectionViewController(self, shouldDeselectItem: item, in: section) ?? true
  }

  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    itemSelectionDelegate.shouldSelctItem(at: indexPath)
  }

  public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    itemSelectionDelegate.shouldDeselectItem(at: indexPath)
  }

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    itemSelectionDelegate.selectItem(at: indexPath, where: { $0.isEqual(to: $1) })
  }

  public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    itemSelectionDelegate.deselectItem(at: indexPath, where: { $0.isEqual(to: $1) })
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

  /// Handler invoked whenn scroll deceleration ends.
  open func didEndDeceleratingFromDragging() {}

  /// Handler invoked when the collection view scrolls.
  open func didScroll() {}

  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    willBeginDragging()
  }

  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    didEndDragging(willDecelerate: decelerate)
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    didEndDeceleratingFromDragging()
  }

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    refreshControlDelegate.layoutRefreshControlsIfNeeded()
    
    didScroll()
    delegate?.collectionViewControllerDidScroll(self)
  }

  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    for handler in endScrollingAnimationHandlers {
      handler()
    }

    endScrollingAnimationHandlers = []
  }

  // MARK: - Pull-to-Refresh Management

  private func willPullToRefresh() -> Bool {
    delegate?.collectionViewControllerWillPullToRefresh(self) ?? false
  }

  private func didPullToRefresh() {
    collectionView.isScrollEnabled = false
    delegate?.collectionViewControllerDidPullToRefresh(self)
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
    updateSnapshot(with: filterDelegate.filteredDataSet)
  }

  // MARK: - Layout Management

  private func layoutFactory() -> UICollectionViewLayout {
    guard let layout = delegate?.collectionViewControllerCollectionViewLayout(self) else {
      log(.debug) { "Creating collection view layout... WARN: No collection view layout provided, please implement the delegate method collectionViewControllerCollectionViewLayout(_:)" }

      return UICollectionViewLayout()
    }

    return layout
  }

  /// Invalidates the collection view layout, reapplying it to the collection
  /// view again.
  public func invalidateCollectionViewLayout() {
    stateMachine.invalidate(\UICollectionView.collectionViewLayout)
  }

  // MARK: - Updating

  open func update(check: StateValidator) {
    if check.isDirty(\UICollectionView.collectionViewLayout) {
      collectionView.setCollectionViewLayout(layoutFactory(), animated: hasViewAppeared)
    }

    if check.isDirty(\CollectionViewController.dataSet) {
      updateSnapshot(with: dataSet)
      itemSelectionDelegate.dataSet = dataSet
      filterDelegate.dataSet = dataSet
    }
  }
}
