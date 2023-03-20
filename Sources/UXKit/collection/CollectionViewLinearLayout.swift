// © GHOZT

import UIKit

/// A custom `UICollectionViewFlowLayout` with linear orientation (horizontal or
/// vertical).
public class CollectionViewLinearLayout: UICollectionViewFlowLayout {
  /// The orientation of the collection view in the
  /// `DataCollectionViewController`.
  public var orientation: UICollectionView.ScrollDirection = .horizontal { didSet { if orientation != oldValue { invalidateLayout() } } }

  /// The width of the section separator up to the last section of the
  /// collection view (the last section has no separator after it).
  public var sectionSeparatorWidth: CGFloat = 0.0 { didSet { if sectionSeparatorWidth != oldValue { invalidateLayout() } } }

  /// The color of the section separator, defaults to transparent.
  public var sectionSeparatorColor: UIColor = .clear { didSet { if sectionSeparatorColor != oldValue { invalidateLayout() } } }

  /// The width of the cell separator up the the last cell of each section (the
  /// last cell of each section has no separator after it).
  public var cellSeparatorWidth: CGFloat = 0.0 { didSet { if cellSeparatorWidth != oldValue { invalidateLayout() } } }

  /// The color of the cell separator, defaults to transparent.
  public var cellSeparatorColor: UIColor = .clear { didSet { if cellSeparatorColor != oldValue { invalidateLayout() } } }

  /// The padding between the separator and the cell before and/or after it.
  public var separatorPadding: CGFloat = 0.0 { didSet { if separatorPadding != oldValue { invalidateLayout() } } }

  public override func prepare() {
    super.prepare()

    register(SeparatorView.self, forDecorationViewOfKind: SeparatorView.className)
  }

  public override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let collectionView = collectionView else {
      return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }

    let cellFrame = layoutAttributesForItem(at: indexPath)?.frame ?? .zero
    let layoutAttributes = LayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
    let isLastCell = indexPath.item >= (collectionView.numberOfItems(inSection: indexPath.section) - 1)
    let isLastSection = indexPath.section >= (collectionView.numberOfSections - 1)

    let separatorWidth = isLastCell ? sectionSeparatorWidth : cellSeparatorWidth
    let separatorColor = isLastCell ? sectionSeparatorColor : cellSeparatorColor

    if (isLastCell && isLastSection) || separatorWidth == 0.0 {
      layoutAttributes.frame = .zero
    }
    else {
      switch elementKind {
      case SeparatorView.className:
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
      if let t = layoutAttributesForDecorationView(ofKind: SeparatorView.className, at: layoutAttribute.indexPath) {
        layoutAttributes.append(t)
      }
    }

    return layoutAttributes
  }
}

private class LayoutAttributes: UICollectionViewLayoutAttributes {
  var separatorColor: UIColor = .clear
}

private class SeparatorView: UICollectionReusableView {
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)

    if let layoutAttributes = layoutAttributes as? LayoutAttributes {
      backgroundColor = layoutAttributes.separatorColor
    }
  }
}
