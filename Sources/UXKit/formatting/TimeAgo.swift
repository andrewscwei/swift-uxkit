public enum TimeAgo: CustomStringConvertible {
  case justNow
  case minutes(num: Int)
  case hours(num: Int)
  case days(num: Int)
  case years(num: Int)

  public var description: String {
    switch self {
    case .justNow: return "Now"
    case .minutes(let num): return num == 1 ? "1m" : String(format: "%dm", num)
    case .hours(let num): return num == 1 ? "1h" : String(format: "%dh", num)
    case .days(let num): return num == 1 ? "1d" : String(format: "%dd", num)
    case .years(let num): return num == 1 ? "1y" : String(format: "%dy", num)
    }
  }
}
