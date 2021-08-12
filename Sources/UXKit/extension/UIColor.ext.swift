// © Sybl

import UIKit

extension UIColor {

  /// Initializes and creates a color object using the specified opacity and hex number value.
  ///
  /// - Parameters:
  ///   - hex: The hex number value.
  ///   - alpha: The opacity.
  convenience public init(_ hex: Int, alpha: CGFloat = 1.0) {
    self.init(
      red: CGFloat((hex >> 16) & 0xFF) / 255,
      green: CGFloat((hex >> 8) & 0xFF) / 255,
      blue: CGFloat(hex & 0xFF) / 255,
      alpha: alpha
    )
  }

  /// Initializes and creates a color object using the specified opacity and hex code in #RRGGBB
  /// format.
  ///
  /// - Parameters:
  ///   - hex: The hex code in #RRGGBB format.
  ///   - alpha: The opacity.
  convenience public init?(_ hex: String, alpha: CGFloat = 1.0) {
    let r, g, b: CGFloat

    if hex.hasPrefix("#") {
      let start = hex.index(hex.startIndex, offsetBy: 1)
      let hexColor = String(hex[start...])

      if hexColor.count == 6 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
          g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
          b = CGFloat(hexNumber & 0x0000ff) / 255

          self.init(red: r, green: g, blue: b, alpha: alpha)
          return
        }
      }
    }

    return nil
  }

  /// Creates and returns a color object that has the same color space and component values as the
  /// receiver, but has an alpha component of `1.0`.
  public var opaque: UIColor { return self.withAlphaComponent(1.0) }

  /// Creates and returns a color object that has the same color space and component values as the
  /// receiver, but has an alpha component of `0.8`.
  public var dimmed: UIColor { return self.withAlphaComponent(0.8) }

  /// Creates and returns a color object that has the same color space and component values as the
  /// receiver, but has an alpha component of `0.4`.
  public var faded: UIColor { return self.withAlphaComponent(0.4) }

  /// Creates and returns a color object that has the same color space and component values as the
  /// receiver, but has an alpha component of `0.1`.
  public var translucent: UIColor { return self.withAlphaComponent(0.1) }

  /// Creates and returns a color object that has the same color space and component values as the
  /// receiver, but has an alpha component of `0.0`.
  public var transparent: UIColor { return self.withAlphaComponent(0.0) }
}
