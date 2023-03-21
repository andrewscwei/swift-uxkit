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

  public static func fooLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .zero

    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50.0))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)

    let layout = UICollectionViewCompositionalLayout(section: section)

    return layout
  }
}
