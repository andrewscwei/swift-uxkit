// © GHOZT

import UIKit

/// A custom `UIViewController` that manages a `UICollectionView` whose items
/// are derived from a `UICollectionViewDiffableDataSource`. Since items are
/// expected to be diffable, their values must be unique across sections even if
/// they are the same type.
open class CollectionViewController<S: Hashable & CaseIterable, I: Hashable>: UIViewController, UICollectionViewDelegate, StateMachineDelegate {

  // MARK: - Delegation

  public weak var delegate: CollectionViewControllerDelegate?

  private lazy var itemSelectionDelegate = CollectionViewItemSelectionDelegate<S, I>(
    collectionView: collectionView,
    selectionDidChange: { self.selectionDidChange() },
    shouldSelectItem: { self.shouldSelectItem(item: $0, section: $1) },
    shouldDeselectItem: { self.shouldDeselectItem(item: $0, section: $1) }
  )

  private lazy var scrollDelegate = CollectionViewScrollDelegate<S, I>(collectionView: collectionView)

  private lazy var reloadDelegate = CollectionViewReloadDelegate(
    collectionView: collectionView
  )

  // MARK: - Layout

  public lazy var collectionViewLayout = layoutFactory()
  public lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

  // MARK: - States

  public lazy var stateMachine = StateMachine(self)

  /// Data set of which the collection view data source is derived from.
  ///
  /// Any changes made to this data set is immediately applied to the current
  /// data source snapshot, thus reloading the items in the collection view.
  ///  Though not explicitly enforced, there should be no duplicate items within
  /// the same section (same item across multiple sections is OK).
  ///
  /// TODO: Enforce no duplicate items in each section.
  @Stateful public var dataSet: [S: [I]] = S.allCases.reduce([:]) { $0.merging([$1: []]) { $1 } }

  // MARK: - Properties

  /// The data source object.
  private lazy var dataSource: UICollectionViewDiffableDataSource<S, I> = dataSourceFactory()

  /// Indicates if an item filter currently exists.
  public var hasItemFilter: Bool { false }

  /// Indicates the number of sections.
  public var numberOfSections: Int { dataSource.snapshot().numberOfSections }

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

  /// Distance required to overscroll in order to trigger a reload (consequently
  /// showing the spinner). This value INCLUDES the content insets of the
  /// collection view.
  public var displacementToTriggerReload: CGFloat {
    get { reloadDelegate.displacementToTriggerReload }
    set { reloadDelegate.displacementToTriggerReload = newValue }
  }

  /// Specifies whether user can pull to reload at end of collection (as
  /// opposed to only the front).
  public var canPullFromEndToReload: Bool {
    get { reloadDelegate.canPullFromEndToReload }
    set { reloadDelegate.canPullFromEndToReload = newValue }
  }

  /// Specifies the orientation of the loading spinners.
  public var orientation: UICollectionView.ScrollDirection {
    get { reloadDelegate.orientation }
    set { reloadDelegate.orientation = newValue }
  }

  /// The content insets of the collection view.
  public var contentInsets: UIEdgeInsets {
    get { reloadDelegate.contentInsets }
    set { reloadDelegate.contentInsets = newValue }
  }

  // MARK: - Life Cycle

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(collectionView)

    collectionView.backgroundColor = .clear
    collectionView.bounces = true
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.dataSource = dataSource
    collectionView.delegate = self
    collectionView.autoLayout { $0.alignToSuperview() }
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    stateMachine.start()
    itemSelectionDelegate.stateMachine.start()
    scrollDelegate.stateMachine.start()
    reloadDelegate.stateMachine.start()
  }

  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    reloadDelegate.stateMachine.stop()
    scrollDelegate.stateMachine.stop()
    itemSelectionDelegate.stateMachine.stop()
    stateMachine.stop()
  }

  // MARK: - Updating

  open func update(check: StateValidator) {
    if check.isDirty(\CollectionViewController.dataSet) {
      updateSnapshot(with: dataSet)
      itemSelectionDelegate.dataSet = dataSet
    }
  }

  // MARK: - Data Management

  /// Factory for the data source object required by the collection view.
  ///
  /// - Returns: The data source object.
  private func dataSourceFactory() -> UICollectionViewDiffableDataSource<S, I> {
    let dataSource = UICollectionViewDiffableDataSource<S, I>(collectionView: collectionView) { collectionView, indexPath, item in
      let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
      return self.cellFactory(at: indexPath, section: section, item: item)
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
  }

  // MARK: - Cell Management

  /// Cell factory method.
  ///
  /// - Parameters:
  ///   - indexPath: Index path.
  ///   - section: Section.
  ///   - item: Item.
  ///
  /// - Returns: The cell.
  open func cellFactory(at indexPath: IndexPath, section: S, item: I) -> UICollectionViewCell {
    fatalError("Derived class <\(Self.self)> must implement this method")
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

  private func willPullToReload() -> Bool {
    delegate?.collectionViewControllerWillPullToReload(self) ?? false
  }

  private func didPullToReload() {
    delegate?.collectionViewControllerDidPullToReload(self)
  }

  public func notifyReloadComplete(completion: @escaping () -> Void = {}) {
    reloadDelegate.stopSpinnersIfNeeded(completion: completion)
  }

  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    reloadDelegate.layoutSublayersIfNeeded()
  }

  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    reloadDelegate.layoutSubviewsIfNeeded()
    
    delegate?.collectionViewControllerDidScroll(self)
  }

  open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    reloadDelegate.startSpinnersIfNeeded()
  }

  // MARK: - Layout Management

  open func layoutFactory() -> UICollectionViewLayout {
    DataCollectionViewFlowLayout()
  }
}
