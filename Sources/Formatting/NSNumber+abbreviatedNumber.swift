import Foundation

extension NSNumber {

  /// Returns the abbreviated string of an integer (i.e. "1K", "1M", etc.).
  ///
  /// To localize the returned string, the app can create an extension of
  /// `AbbreviatedNumberSuffix` and conform to the `Localized` protocol.
  ///
  /// - Parameters:
  ///   - int: The integer.
  /// - Returns: The abbreviated string.
  public class func abbreviatedNumber(from int: Int) -> String {
    let formatter = NumberFormatter()

    typealias Abbreviation = (threshold: Double, divisor: Double, suffix: AbbreviatedNumberSuffix)

    let abbreviations: [Abbreviation] = [
      (0, 1, .underOneThousand),
      (1000.0, 1000.0, .thousands),
      (100_000.0, 1_000_000.0, .millions),
      (100_000_000.0, 1_000_000_000.0, .billions),
      (100_000_000_000.0, 1_000_000_000_000.0, .trillions),
      (100_000_000_000_000.0, 1_000_000_000_000_000.0, .quadrillions),
    ]

    let startValue = Double(abs(int))
    let abbreviation: Abbreviation = {
      var prevAbbreviation = abbreviations[0]
      for tmpAbbreviation in abbreviations {
        if (startValue < tmpAbbreviation.threshold) {
          break
        }
        prevAbbreviation = tmpAbbreviation
      }
      return prevAbbreviation
    }()

    let value = Double(int) / abbreviation.divisor
    formatter.positiveSuffix = (abbreviation.suffix as? Localized)?.localizedDescription ?? abbreviation.suffix.description
    formatter.negativeSuffix = (abbreviation.suffix as? Localized)?.localizedDescription ?? abbreviation.suffix.description
    formatter.allowsFloats = true
    formatter.minimumIntegerDigits = 1
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 1

    return formatter.string(from: NSNumber(value: value))!
  }
}
