// © Sybl

import UIKit

public class DataCollectionViewFlowLayout: UICollectionViewFlowLayout {
  
  public var orientation: UICollectionView.ScrollDirection = .horizontal { didSet { invalidateLayout() } }

  public var sectionSeparatorWidth: CGFloat = 0.0 { didSet { invalidateLayout() } }

  public var sectionSeparatorColor: UIColor = .clear { didSet { invalidateLayout() } }

  public var cellSeparatorWidth: CGFloat = 0.0 { didSet { invalidateLayout() } }

  public var cellSeparatorColor: UIColor = .clear { didSet { invalidateLayout() } }

  public var separatorPadding: CGFloat = 0.0

  public override func prepare() {
    super.prepare()
    register(DataCollectionSeparatorView.self, forDecorationViewOfKind: DataCollectionSeparatorView.className)
  }

  public override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let collectionView = collectionView else {
      return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }

    let cellFrame = layoutAttributesForItem(at: indexPath)?.frame ?? .zero
    let layoutAttributes = DataCollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
    let isLastCell = indexPath.item >= (collectionView.numberOfItems(inSection: indexPath.section) - 1)
    let isLastSection = indexPath.section >= (collectionView.numberOfSections - 1)

    let separatorWidth = isLastCell ? sectionSeparatorWidth : cellSeparatorWidth
    let separatorColor = isLastCell ? sectionSeparatorColor : cellSeparatorColor

    if (isLastCell && isLastSection) || separatorWidth == 0.0 {
      layoutAttributes.frame = .zero
    }
    else {
      switch elementKind {
      case DataCollectionSeparatorView.className:
        switch orientation {
        case .vertical:
          let x = cellFrame.minX
          let y = cellFrame.maxY - separatorWidth * 0.5 + separatorPadding
          let w = cellFrame.width
          let h = separatorWidth
          layoutAttributes.frame = CGRect(x: x, y: y, width: w, height: h)
        default:
          let x = cellFrame.maxX - separatorWidth * 0.5 + separatorPadding
          let y = cellFrame.minY
          let w = separatorWidth
          let h = cellFrame.height
          layoutAttributes.frame = CGRect(x: x, y: y, width: w, height: h)
        }
      default: break
      }
    }

    layoutAttributes.zIndex = 1
    layoutAttributes.separatorColor = separatorColor

    return layoutAttributes
  }

  public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let baseLayoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }

    var layoutAttributes = baseLayoutAttributes
    baseLayoutAttributes.filter { $0.representedElementCategory == .cell }.forEach { layoutAttribute in
      if let t = layoutAttributesForDecorationView(ofKind: DataCollectionSeparatorView.className, at: layoutAttribute.indexPath) {
        layoutAttributes.append(t)
      }
    }

    return layoutAttributes
  }
}

private class DataCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
  var separatorColor: UIColor = .clear
}

private class DataCollectionSeparatorView: UICollectionReusableView {
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)

    if let layoutAttributes = layoutAttributes as? DataCollectionViewLayoutAttributes {
      backgroundColor = layoutAttributes.separatorColor
    }
  }
}
