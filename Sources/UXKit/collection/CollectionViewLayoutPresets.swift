import UIKit

public struct CollectionViewLayoutPresets {

  @available(iOS 14.5, *)
  public static func listLayout(
    separatorColor: UIColor? = nil,
    separatorInsets: NSDirectionalEdgeInsets? = nil
  ) -> UICollectionViewCompositionalLayout {
    var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
    configuration.backgroundColor = .clear

    if let color = separatorColor {
      configuration.separatorConfiguration.color = color
    }

    if let insets = separatorInsets {
      configuration.separatorConfiguration.bottomSeparatorInsets = insets
    }

    return UICollectionViewCompositionalLayout.list(using: configuration)
  }

  public static func linearLayout(
    direction: UICollectionView.ScrollDirection = .horizontal,
    itemSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)),
    itemContentInsets: NSDirectionalEdgeInsets = .zero,
    groupSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalHeight(1.0), heightDimension: .fractionalHeight(1.0)),
    groupContentInsets: NSDirectionalEdgeInsets = .zero,
    sectionContentInsets: NSDirectionalEdgeInsets = .zero,
    interGroupSpacing: CGFloat = 0
  ) -> UICollectionViewCompositionalLayout {
    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.scrollDirection = direction

    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = itemContentInsets

    let group = direction == .horizontal ? NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item]) : NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.contentInsets = groupContentInsets

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = sectionContentInsets
    section.interGroupSpacing = interGroupSpacing

    let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)

    return layout
  }
}
