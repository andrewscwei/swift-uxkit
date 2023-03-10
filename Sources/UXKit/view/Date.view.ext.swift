// © GHOZT

import BaseKit
import Foundation

extension Date {
  /// Returns the date in ISO 8601 (`yyyy-MM-dd HH:mm:ss.SSSZ`) format.
  @available(iOS 11.0, *)
  public var iso8601: String {
    return Formatter.iso8601.string(from: self)
  }

  /// Returns a string representation of how much time has passed since this
  /// `Date`.
  ///
  /// In order for the correct string to be displayed, the app must define the
  /// following strings in `Localizable.strings`:
  ///   1. `LTXT_TIME_1_YEAR` and `LTXT_TIME_N_YEARS`: String representations of
  ///      1 year and N years respectively, where N is an integer.
  ///   2. `LTXT_TIME_1_DAY` and `LTXT_TIME_N_DAYS`: String representations of 1
  ///      day and N days respectively, where N is an integer.
  ///   3. `LTXT_TIME_1_HOUR` and `LTXT_TIME_N_HOURS`: String representations of
  ///      1 hour and N hours respectively, where N is an integer.
  ///   4. `LTXT_TIME_1_MINUTE` and `LTXT_TIME_N_MINUTES`: String
  ///      representations of 1 minute and N minutes respectively, where N is an
  ///      integer.
  ///   5. `LTXT_TIME_JUST_NOW`: String representation of any duration under a
  ///      minute.
  ///
  /// - Returns: String representation of how much time has passed since this
  ///            `Date`.
  public func shortTimeAgoSinceNow() -> String {
    let interval = Calendar.current.dateComponents([.year, .day, .hour, .minute], from: self, to: Date())

    if let val = interval.year, val > 0 {
      return val == 1 ? ltxt("LTXT_TIME_1_YEAR", default: "1y") : String(format: ltxt("LTXT_TIME_N_YEARS", default: "%dy"), val)
    }

    if let val = interval.day, val > 0 {
      return val == 1 ? ltxt("LTXT_TIME_1_DAY", default: "1d") : String(format: ltxt("LTXT_TIME_N_DAYS", default: "%dd"), val)
    }

    if let val = interval.hour, val > 0 {
      return val == 1 ? ltxt("LTXT_TIME_1_HOUR", default: "1h") : String(format: ltxt("LTXT_TIME_N_HOURS", default: "%dh"), val)
    }

    if let val = interval.minute, val > 0 {
      return val == 1 ? ltxt("LTXT_TIME_1_MINUTE", default: "1m") : String(format: ltxt("LTXT_TIME_N_MINUTES", default: "%dm"), val)
    }

    return ltxt("LTXT_TIME_JUST_NOW", default: "Now")
  }
}
