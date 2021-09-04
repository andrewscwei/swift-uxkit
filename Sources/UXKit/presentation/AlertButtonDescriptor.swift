// © Sybl

import UIKit

/// A type that describes the appearance and behavior of a button in an alert popup.
public typealias AlertButtonDescriptor = (

  /// The label of the button.
  label: String,

  /// The `UIAlertAction.Style` of the button.
  style: UIAlertAction.Style,

  /// Handler invoked when the button is tapped.
  handler: (() -> Void)?
)
