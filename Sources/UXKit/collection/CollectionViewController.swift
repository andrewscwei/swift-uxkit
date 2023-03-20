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

  private lazy var scrollDelegate = CollectionViewScrollDelegate<S, I>(collectionView: collectionView)

  private lazy var reloadDelegate = CollectionViewReloadDelegate(
    collectionView: collectionView,
    willPullToReload: { self.willPullToReload() },
    didPullToReload: { self.didPullToReload() }
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

  /// Reload control spinner at the front of the collection view.
  public var frontSpinner: (any CollectionViewSpinner)? {
    get { reloadDelegate.frontSpinner }
    set { reloadDelegate.frontSpinner = newValue }
  }

  /// Reload control spinner at the end of the collection view.
  public var endSpinner: (any CollectionViewSpinner)? {
    get { reloadDelegate.endSpinner }
    set { reloadDelegate.endSpinner = newValue }
  }

  // MARK: - Life Cycle

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(collectionView)

    collectionView.backgroundColor = .clear
    collectionView.bounces = true
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.dataSource = dataSource
    collectionView.delaysContentTouches = false
    collectionView.delegate = self
    collectionView.autoLayout { $0.alignToSuperview() }

    frontSpinner = delegate?.collectionViewControllerFrontSpinner(self)
    endSpinner = delegate?.collectionViewControllerEndSpinner(self)
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

  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    reloadDelegate.revealSpinnersIfNeeded()
    
    delegate?.collectionViewControllerDidScroll(self)
  }

  open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    reloadDelegate.startSpinnersIfNeeded()
  }

  // MARK: - Factories

  private func dataSourceFactory() -> UICollectionViewDiffableDataSource<S, I> {
    let dataSource = UICollectionViewDiffableDataSource<S, I>(collectionView: collectionView) { collectionView, indexPath, item in
      let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
      return self.cellFactory(at: indexPath, section: section, item: item)
    }

    return dataSource
  }

  private func cellFactory(at indexPath: IndexPath, section: S, item: I) -> UICollectionViewCell {
    guard let cell = delegate?.collectionViewController(self, cellAtIndexPath: indexPath, section: section, item: item) else {
      fatalError("CollectionViewController requires a CollectionViewControllerDelegate to implement collectionViewController(_:cellAtIndexPath:section:item:).")
    }

    return cell
  }

  /// Factory method for the `UICollectionViewLayout` object of the collection
  /// view.
  ///
  /// Subclasses can override this method to create custom layouts.
  ///
  /// - Returns: `UICollectionViewLayout` instance.
  open func layoutFactory() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .zero

    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50.0))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    //    section.boundarySupplementaryItems = [headerLayout()]

    return UICollectionViewCompositionalLayout(section: section)
  }
}
