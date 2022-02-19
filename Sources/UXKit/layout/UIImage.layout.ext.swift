// © GHOZT

import UIKit

extension UIImage {

  /// Sets the shorter edge of this image to the specified length and resizes the longer edge while
  /// maintaining the original aspect ratio.
  ///
  /// - Parameters:
  ///   - min: The length to resize the target edge to.
  ///
  /// - Returns: The resized image.
  public func minLengthResize(min: CGFloat) -> UIImage? { UIImage.minLengthResize(self, min: min) }

  /// Sets the longer edge of this image to the specified length and resizes the shorter edge while
  /// maintaining the original aspect ratio.
  ///
  /// - Parameters:
  ///   - min: The length to resize the target edge to.
  ///
  /// - Returns: The resized image.
  public func maxLengthResize(max: CGFloat) -> UIImage? { UIImage.maxLengthResize(self, max: max) }

  /// Fills this image to the specified size while maintaining aspect ratio.
  ///
  /// - Parameters:
  ///   - size: The size to fill.
  ///
  /// - Returns: The filled image.
  public func aspectFillResize(to size: CGSize) -> UIImage? { UIImage.aspectFillResize(self, to: size) }

  /// Fits this image within the specified size while maintaining aspect ratio. Unused space will be
  /// cropped, so the size of the image may be smaller than the fitted size.
  ///
  /// - Parameters:
  ///   - size: The size to fit.
  ///
  /// - Returns: The fitted image.
  public func aspectFitResize(to size: CGSize) -> UIImage? { UIImage.aspectFitResize(self, to: size) }

  /// Sets the shorter edge of this image to the specified length and resizes the longer edge while
  /// maintaining the original aspect ratio.
  ///
  /// - Parameters:
  ///   - image: The image to resize.
  ///   - min: The length to resize the target edge to.
  ///
  /// - Returns: The resized image.
  public class func minLengthResize(_ image: UIImage, min: CGFloat) -> UIImage? {
    let aspectRatio = image.size.width / image.size.height
    let isLandscape = aspectRatio > 1
    let size = CGSize(width: isLandscape ? min * aspectRatio : min, height: isLandscape ? min : min / aspectRatio)

    var rect: CGRect = .zero
    rect.size.width = size.width
    rect.size.height = size.height
    rect.origin.x = (size.width - rect.size.width) / 2
    rect.origin.y = (size.height - rect.size.height) / 2

    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    image.draw(in: rect)
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return resizedImage
  }

  /// Sets the longer edge of this image to the specified length and resizes the shorter edge while
  /// maintaining the original aspect ratio.
  ///
  /// - Parameters:
  ///   - image: The image to resize.
  ///   - min: The length to resize the target edge to.
  ///
  /// - Returns: The resized image.
  public class func maxLengthResize(_ image: UIImage, max: CGFloat) -> UIImage? {
    let aspectRatio = image.size.width / image.size.height
    let isLandscape = aspectRatio > 1
    let size = CGSize(width: isLandscape ? max : max * aspectRatio, height: isLandscape ? max / aspectRatio : max)

    var rect: CGRect = .zero
    rect.size.width = size.width
    rect.size.height = size.height
    rect.origin.x = (size.width - rect.size.width) / 2
    rect.origin.y = (size.height - rect.size.height) / 2

    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    image.draw(in: rect)
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return resizedImage
  }

  /// Fills an image to the specified size while maintaining aspect ratio.
  ///
  /// - Parameters:
  ///   - image: The image to use.
  ///   - size: The size to fill.
  ///
  /// - Returns: The filled image.
  public class func aspectFillResize(_ image: UIImage, to size: CGSize) -> UIImage? {
    let aspectRatio = min(size.width/image.size.width, size.height/image.size.height)

    var rect = CGRect.zero
    rect.size.width = image.size.width * aspectRatio
    rect.size.height = image.size.height * aspectRatio
    rect.origin.x = (size.width - rect.size.width) / 2
    rect.origin.y = (size.height - rect.size.height) / 2

    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    image.draw(in: rect)
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return resizedImage
  }

  /// Fits an image within the specified size while maintaining aspect ratio. Unused space will be
  /// cropped, so the size of the image may be smaller than the fitted size.
  ///
  /// - Parameters:
  ///   - image: The image to use.
  ///   - size: The size to fit.
  ///
  /// - Returns: The fitted image.
  public class func aspectFitResize(_ image: UIImage, to size: CGSize) -> UIImage? {
    let aspectRatio = max(size.width/image.size.width, size.height/image.size.height)

    var rect = CGRect.zero
    rect.size.width = image.size.width * aspectRatio
    rect.size.height = image.size.height * aspectRatio
    rect.origin.x = (size.width - rect.size.width) / 2
    rect.origin.y = (size.height - rect.size.height) / 2

    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    image.draw(in: rect)
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return resizedImage
  }
}
