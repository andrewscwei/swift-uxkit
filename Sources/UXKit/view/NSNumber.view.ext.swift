// © GHOZT

import BaseKit
import Foundation

extension NSNumber {

  /// Returns the abbreviated string of an integer (i.e. "1K", "1M", etc.).
  ///
  /// In order for the correct string to be displayed, the app must define the
  /// following strings in `Localizable.strings`:
  ///   1. `LTXT_NUMBER_SUFFIX_THOUSANDS`: Suffix for thousands (i.e. "K").
  ///   2. `LTXT_NUMBER_SUFFIX_MILLIONS`: Suffix for millions (i.e. "M").
  ///   3. `LTXT_NUMBER_SUFFIX_BILLIONS`: Suffix for billions (i.e. "B").
  ///   4. `LTXT_NUMBER_SUFFIX_TRILLIONS`: Suffix for trillions (i.e. "T").
  ///   5. `LTXT_NUMBER_SUFFIX_QUADRILLION`: Suffix for quadrillions (i.e. "Q").
  ///
  /// - Parameter int: The integer.
  /// - Returns: The abbreviated string.
  public class func abbreviatedNumber(from int: Int) -> String {
    let formatter = NumberFormatter()

    typealias Abbreviation = (threshold: Double, divisor: Double, suffix: String)

    let abbreviations: [Abbreviation] = [
      (0, 1, ""),
      (1000.0, 1000.0, ltxt("LTXT_NUMBER_SUFFIX_THOUSANDS", default: "K")),
      (100_000.0, 1_000_000.0, ltxt("LTXT_NUMBER_SUFFIX_MILLIONS", default: "M")),
      (100_000_000.0, 1_000_000_000.0, ltxt("LTXT_NUMBER_SUFFIX_BILLIONS", default: "B")),
      (100_000_000_000.0, 1_000_000_000_000.0, ltxt("LTXT_NUMBER_SUFFIX_TRILLIONS", default: "T")),
      (100_000_000_000_000.0, 1_000_000_000_000_000.0, ltxt("LTXT_NUMBER_SUFFIX_QUADRILLION", default: "Q")),
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
    formatter.positiveSuffix = abbreviation.suffix
    formatter.negativeSuffix = abbreviation.suffix
    formatter.allowsFloats = true
    formatter.minimumIntegerDigits = 1
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 1

    return formatter.string(from: NSNumber(value: value))!
  }
}
