// © GHOZT

import UIKit

extension UIFont {

  public func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    let descriptor = fontDescriptor.withSymbolicTraits(traits)
    return UIFont(descriptor: descriptor!, size: 0.0)
  }

  public var bold: UIFont {
    return withTraits(traits: .traitBold)
  }

  public var italic: UIFont {
    return withTraits(traits: .traitItalic)
  }
}
