// © GHOZT

import UIKit

// TODO: Scrolling, pull to refresh 

/// A custom `UIViewController` that manages a `UICollectionView` whose items
/// are derived from a `UICollectionViewDiffableDataSource`. Since items are
/// expected to be diffable, their values must be unique across sections even if
/// they are the same type.
///
/// `CollectionViewController` has native support for the following features:
///   - item filtering
///   - single/multiple cell selection (see `selectionMode`), persisted across
///     cell reloads
///   - customizable pull-to-reload triggers and indicators from both ends of
///     the collection view (see `frontSpinner`, `endSpinner`, and
///     `willPullToReload(in:)`)
open class CollectionViewController<S: Hashable & CaseIterable, I: Hashable>: UIViewController, UICollectionViewDelegate, StateMachineDelegate {

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

  // MARK: - Properties

  /// The data source object.
  private lazy var dataSource: UICollectionViewDiffableDataSource<S, I> = dataSourceFactory()

  /// Indicates if an item filter currently exists.
  public var hasItemFilter: Bool { false }

  /// Indicates the number of sections.
  public var numberOfSections: Int { dataSource.snapshot().numberOfSections }

  /// Specifies how the collection view selects its cells.
  public var selectionMode: CollectionViewSelectionMode {
    get { itemSelectionDelegate.selectionMode }
    set { itemSelectionDelegate.selectionMode = newValue }
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
  }

  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

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

  public func isItemSelected(_ item: I, where predicate: (I, I) -> Bool = { $0.isEqual(to: $1) }) -> Bool { itemSelectionDelegate.isItemSelected(item, where: predicate) }

  public func areAllItemsSelected(in section: S, where predicate: (I, I) -> Bool = { $0.isEqual(to: $1) }) -> Bool { itemSelectionDelegate.areAllItemsSelected(in: section, where: predicate) }

  public func areAllItemsDeselected(in section: S, where predicate: (I, I) -> Bool = { $0.isEqual(to: $1) }) -> Bool { itemSelectionDelegate.areAllItemsDeselected(in: section, where: predicate) }

  @discardableResult public func selectItem(_ item: I, shouldScroll: Bool = true, animated: Bool = true) -> I? {
    guard let item = itemSelectionDelegate.selectItem(item, where: { $0.isEqual(to: $1) }) else { return nil }

//    let shouldAnimate = hasViewAppeared ? shouldScroll && animated : false
//    let scrollPosition: UICollectionView.ScrollPosition = (indexPath.section == 0 && indexPath.item == 0) ? [.top, .left] : [.centeredHorizontally, .centeredVertically]

    return item
  }

  @discardableResult public func selectAllItems(in section: S) -> [I] { itemSelectionDelegate.selectAllItems(in: section, where: { $0.isEqual(to: $1) }) }

  @discardableResult public func deselectItem(_ item: I) -> I? { itemSelectionDelegate.deselectItem(item, where: { $0.isEqual(to: $1) }) }

  @discardableResult public func deselectAllItems(in section: S) -> [I] { itemSelectionDelegate.deselectAllItems(in: section, where: { $0.isEqual(to: $1) }) }

  open func selectionDidChange() {
    stateMachine.invalidate(\CollectionViewController.selectedItem, \CollectionViewController.selectedItems)
    delegate?.collectionViewControllerSelectionDidChange(self)
  }

  open func shouldSelectItem(item: I, section: S) -> Bool {
    delegate?.collectionViewController(self, shouldSelectItem: item, in: section) ?? true
  }

  open func shouldDeselectItem(item: I, section: S) -> Bool {
    delegate?.collectionViewController(self, shouldDeselectItem: item, in: section) ?? true
  }

  // MARK: - Delegation

  public weak var delegate: CollectionViewControllerDelegate?

  private lazy var itemSelectionDelegate = CollectionViewItemSelectionDelegate<S, I>(
    collectionView: collectionView,
    selectionDidChangeHandler: { self.selectionDidChange() },
    shouldSelectItemHandler: { self.shouldSelectItem(item: $0, section: $1) },
    shouldDeselectItemHandler: { self.shouldDeselectItem(item: $0, section: $1) }
  )

  final public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool { itemSelectionDelegate.shouldSelctItem(at: indexPath) }
  final public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool { itemSelectionDelegate.shouldDeselectItem(at: indexPath) }
  final public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { itemSelectionDelegate.selectItem(at: indexPath, where: { $0.isEqual(to: $1) }) }
  final public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) { itemSelectionDelegate.deselectItem(at: indexPath, where: { $0.isEqual(to: $1) }) }

  // MARK: - Layout Management

  open func layoutFactory() -> UICollectionViewLayout {
    DataCollectionViewFlowLayout()
  }
}
