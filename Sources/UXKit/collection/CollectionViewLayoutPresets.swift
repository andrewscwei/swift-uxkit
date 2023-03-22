// © GHOZT

import UIKit

public struct CollectionViewLayoutPresets {

  @available(iOS 14.5, *)
  public static func listLayout(separatorColor: UIColor? = nil, separatorInsets: NSDirectionalEdgeInsets? = nil) -> UICollectionViewCompositionalLayout {
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

  public static func horizontalLayout(sectionContentInsets: NSDirectionalEdgeInsets = .zero, itemContentInsets: NSDirectionalEdgeInsets = .zero) -> UICollectionViewCompositionalLayout {
    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.scrollDirection = .horizontal

    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = itemContentInsets

    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(0.75), heightDimension: .fractionalHeight(1.0))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = sectionContentInsets

    let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)

    return layout
  }
}
