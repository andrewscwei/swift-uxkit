// © GHOZT

/// An option set describing how a `UIView` should be anchored auto layout rules
/// are applied by `AutoLayoutDelegate`.
public struct AutoLayoutAnchorType: OptionSet {
  public let rawValue: Int

  public static let top = AutoLayoutAnchorType(rawValue: 1 << 0)
  public static let right = AutoLayoutAnchorType(rawValue: 1 << 1)
  public static let bottom = AutoLayoutAnchorType(rawValue: 1 << 2)
  public static let left = AutoLayoutAnchorType(rawValue: 1 << 3)
  public static let centerX = AutoLayoutAnchorType(rawValue: 1 << 4)
  public static let centerY = AutoLayoutAnchorType(rawValue: 1 << 5)
  public static let width = AutoLayoutAnchorType(rawValue: 1 << 6)
  public static let height = AutoLayoutAnchorType(rawValue: 1 << 7)
  public static let center: AutoLayoutAnchorType = [.centerX, .centerY]
  public static let x: AutoLayoutAnchorType = [.left, .right]
  public static let y: AutoLayoutAnchorType = [.top, .bottom]
  public static let size: AutoLayoutAnchorType = [.width, .height]

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public func contains(_ alignment: AutoLayoutAnchorType) -> Bool {
    switch alignment {
    default: return self.intersection(alignment) != []
    }
  }
}
