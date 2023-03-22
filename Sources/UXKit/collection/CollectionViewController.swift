// © GHOZT

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

  // MARK: - Life Cycle

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(collectionView)

    collectionView.collectionViewLayout = layoutFactory()
    collectionView.backgroundColor = .clear
    collectionView.bounces = true
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.dataSource = dataSource
    collectionView.delaysContentTouches = false
    collectionView.delegate = self
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

  open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    itemSelectionDelegate.shouldSelctItem(at: indexPath)
  }

  open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    itemSelectionDelegate.shouldDeselectItem(at: indexPath)
  }

  open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    itemSelectionDelegate.selectItem(at: indexPath, where: { $0.isEqual(to: $1) })
  }

  open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    itemSelectionDelegate.deselectItem(at: indexPath, where: { $0.isEqual(to: $1) })
  }

  // MARK: - Scroll Management

  public func scrollToBeginning(animated: Bool = true) {
    scrollDelegate.scrollToBeginning(animated: animated)
  }

  public func scrollToEnd(animated: Bool = true) {
    scrollDelegate.scrollToEnd(animated: animated)
  }

  public func scrollToItem(_ item: I, animated: Bool = true) {
    scrollDelegate.scrollToItem(item, animated: animated)
  }

  // MARK: - Pull-to-Refresh Management

  private func willPullToRefresh() -> Bool {
    delegate?.collectionViewControllerWillPullToRefresh(self) ?? false
  }

  private func didPullToRefresh() {
    delegate?.collectionViewControllerDidPullToRefresh(self)
  }

  public func notifyRefreshComplete(completion: @escaping () -> Void = {}) {
    refreshControlDelegate.deactivateRefreshControlsIfNeeded(completion: completion)
  }

  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    refreshControlDelegate.layoutRefreshControlsIfNeeded()
    
    delegate?.collectionViewControllerDidScroll(self)
  }

  open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    refreshControlDelegate.activateRefreshControlsIfNeeded()
  }

  // MARK: - Filter Management

  private func filteredDataSetDidChange() {
    updateSnapshot(with: filterDelegate.filteredDataSet)
  }

  // MARK: - Layout Management

  /// Factory method for the `UICollectionViewLayout` object of the collection
  /// view.
  ///
  /// Subclasses can override this method to create custom layouts.
  ///
  /// - Returns: `UICollectionViewLayout` instance.
  private func layoutFactory() -> UICollectionViewLayout {
    if let layout = delegate?.collectionViewControllerCollectionViewLayout(self) {
      return layout
    }
    
    var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
    configuration.backgroundColor = .clear
    return UICollectionViewCompositionalLayout.list(using: configuration)
  }

  // MARK: - Updating

  open func update(check: StateValidator) {
    if check.isDirty(\CollectionViewController.dataSet) {
      updateSnapshot(with: dataSet)
      itemSelectionDelegate.dataSet = dataSet
      filterDelegate.dataSet = dataSet
    }
  }
}
