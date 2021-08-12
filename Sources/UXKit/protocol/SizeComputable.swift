// © Sybl

import UIKit

public protocol SizeComputable: AnySizeComputable  {

  /// Attributes used to compute the size of the conforming object.
  associatedtype SizeAttributes

  /// Returns the computed size that fits this object based on a set of attributes.
  ///
  /// - Parameters:
  ///   - attributes: Attributes that affect the calculation of the size.
  ///
  /// - Returns: The computed `CGSize`.
  static func sizeThatFits(with attributes: SizeAttributes?) -> CGSize
}

extension SizeComputable {

  public func sizeThatFits() -> CGSize {
    return Self.sizeThatFits(with: nil)
  }
}
