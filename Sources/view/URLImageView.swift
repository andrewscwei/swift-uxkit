import SDWebImage
import UIKit

/// A custom `UIImageView` that is capable of loading images from a `URL`.
public class URLImageView: UIImageView {
  public weak var delegate: URLImageViewDelegate?

  /// A weak reference to the aspect ratio constraint of this view. This is
  /// necessary in order for the view to properly resize itself based on the
  /// actual dimension of the loaded image/video.
  private weak var aspectRatioConstraint: NSLayoutConstraint?

  public var url: URL? {
    didSet {
      guard url != oldValue else { return }

      invalidateImage()

      if url == nil {
        delegate?.imageViewDidClear(self)
      }
    }
  }

  open override var image: UIImage? {
    didSet {
      guard image != oldValue else { return }
      updateAspectRatio()
    }
  }

  public var imageSize: CGSize { image?.size ?? .zero }

  convenience public init() {
    self.init(frame: .zero)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    didInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    didInit()
  }

  private func didInit() {
    contentMode = .scaleAspectFill
    backgroundColor = .clear
    clipsToBounds = true

    invalidateImage()
  }

  public func clear() {
    url = nil
  }

  private func invalidateImage() {
    if url == nil {
      unload()
    }
    else {
      load()
    }
  }

  private func unload() {
    sd_cancelCurrentImageLoad()
    image = nil
  }

  private func load() {
    guard let url = url else { return }

    sd_cancelCurrentImageLoad()

    let isFilePath = FileManager.default.fileExists(atPath: url.path)

    if isFilePath {
      if let image = UIImage(contentsOfFile: url.path) {
        self.image = image
        delegate?.imageView(self, didFinishingLoadingImage: image)
      }
      else {
        self.image = nil
        delegate?.imageView(self, didFailToLoadImageWithError: URLImageView.Error.loadFromDisk)
      }
    }
    else {
      sd_setImage(with: url, placeholderImage: nil, options: []) { image, error, cacheType, targetURL in
        DispatchQueue.main.async {

          if let image = image {
            self.image = image
            self.delegate?.imageView(self, didFinishingLoadingImage: image)
          }
          else {
            self.image = nil
            self.delegate?.imageView(self, didFailToLoadImageWithError: error ?? URLImageView.Error.loadFromNetwork)
          }
        }
      }
    }
  }

  /// Updates the aspect ratio constraint of this view. The constraint is based
  /// on the size of the current displayed `UIImage`, and automatically changes
  /// the view's height according to the aspect ratio of the image relative to
  /// the view's width.
  private func updateAspectRatio() {
    // First remove the current constraint, if it exists.
    if let oldConstraint = aspectRatioConstraint {
      removeConstraint(oldConstraint)
    }

    guard let size = image?.size, size != .zero else { return }

    // Then apply the new constraint and lower its priority so externally
    // applied constraints can override this.
    let newConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: size.height / size.width, constant: 0)
    newConstraint.priority = UILayoutPriority(rawValue: 999)
    addConstraint(newConstraint)

    // Save a weak reference of the new constraint so it can get referred back
    // in this method.
    aspectRatioConstraint = newConstraint
  }
}
