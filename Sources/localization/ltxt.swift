import Foundation

/// Convenience method for fetching a localized string from the main bundle.
/// Providing a comment is optional and is otherwise automatically set to the
/// same value as the key.
///
/// - Parameters:
///   - key: Localization key.
///   - defaultString: Optional fallback string for this localization, defaults
///                    to the localization key.
///   - comment: Optional comment for this localization, defaults to the value
///              of the localization key.
/// - Returns: The localized string.
public func ltxt(_ key: String, default defaultString: String? = nil, comment: String? = nil) -> String {
  return NSLocalizedString(key, tableName: nil, bundle: .main, value: defaultString ?? key, comment: comment ?? key)
}
