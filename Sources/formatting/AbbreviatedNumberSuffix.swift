public enum AbbreviatedNumberSuffix: CustomStringConvertible {
  case underOneThousand
  case thousands
  case millions
  case billions
  case trillions
  case quadrillions

  public var description: String {
    switch self {
    case .underOneThousand: return ""
    case .thousands: return "K"
    case .millions: return "M"
    case .billions: return "B"
    case .trillions: return "T"
    case .quadrillions: return "Q"
    }
  }
}
