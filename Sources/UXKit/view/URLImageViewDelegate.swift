// © GHOZT

import UIKit

public protocol URLImageViewDelegate: AnyObject {

  /// Handler invoked when the image finishes loading.
  ///
  /// - Parameters:
  ///   - imageView: The `URLImageView` instance that invoked this delegate method.
  ///   - image: The `UIImage` that was loaded.
  func imageView(_ imageView: URLImageView, didFinishingLoadingImage image: UIImage)

  /// Handler invoked when the image fails to load.
  ///
  /// - Parameters:
  ///   - imageView: The `URLImageView` instance that invoked this delegate method.
  ///   - error: The error.
  func imageView(_ imageView: URLImageView, didFailToLoadImageWithError error: Error)

  /// Handler invoked when the image is cleared.
  ///
  /// - Parameter imageView: The `URLImageView` instance that invoked this delegate method.
  func imageViewDidClear(_ imageView: URLImageView)
}

extension URLImageViewDelegate {

  public func imageView(_ imageView: URLImageView, didFinishingLoadingImage image: UIImage) {}

  public func imageView(_ imageView: URLImageView, didFailToLoadImageWithError error: Error) {}

  public func imageViewDidClear(_ imageView: URLImageView) {}
}
