import Foundation

extension Date {

  /// Returns a string representation of how much time has passed since the
  /// current `Date`.
  ///
  /// To localize the returned string, the app can create an extension of
  /// `TimeAgo` and conform to the `Localized` protocol.
  ///
  /// - Returns: String representation of how much time has passed since this
  ///            `Date`.
  public func shortTimeAgoSinceNow() -> String {
    shortTimeAgoSince(Date())
  }

  /// Returns a string representation of how much time has passed since the
  /// specified `Date`.
  ///
  /// To localize the returned string, the app can create an extension of
  /// `TimeAgo` and conform to the `Localized` protocol.
  ///
  /// - Returns: String representation of how much time has passed since this
  ///            `Date`.
  public func shortTimeAgoSince(_ date: Date) -> String {
    let interval = Calendar.current.dateComponents([.year, .day, .hour, .minute], from: self, to: date)
    let timeAgo: TimeAgo

    if let val = interval.year, val > 0 {
      timeAgo = .years(num: val)
    }
    else if let val = interval.day, val > 0 {
      timeAgo = .days(num: val)
    }
    else if let val = interval.hour, val > 0 {
      timeAgo = .hours(num: val)
    }
    else if let val = interval.minute, val > 0 {
      timeAgo = .minutes(num: val)
    }
    else {
      timeAgo = .justNow
    }

    return (timeAgo as? Localized)?.localizedDescription ?? timeAgo.description
  }
}
