// © GHOZT

import BaseKit
import UIKit

class CollectionViewReloadDelegate {
  /// Internal `StateMachine` instance.
  lazy var stateMachine = StateMachine(self)

  /// The `UICollectionView` this controller controls.
  private let collectionView: UICollectionView

  /// Handler invoked to determine if pulling to reload is enabled.
  private let willPullToReloadHandler: () -> Bool

  /// Handler invoked after pulling to reload.
  private let didPullToReloadHandler: () -> Void

  /// Reload control spinner at the front of the collection view.
  var frontSpinner: (any CollectionViewSpinner)? {
    willSet {
      guard let oldSpinner = frontSpinner else { return }
      oldSpinner.removeFromSuperview()
      frontSpinnerMask = nil
    }

    didSet {
      guard let backgroundView = collectionView.backgroundView, let newSpinner = frontSpinner else { return }
      backgroundView.addSubview(newSpinner)

      let mask = CAGradientLayer()
      mask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
      // HACK: Use -0.01 here because somehow when the start and end points
      // are identical, the layer mask doesn't work at all.
      mask.startPoint = CGPoint(x: -0.01, y: 0.5)
      mask.endPoint = CGPoint(x: 0.0, y: 0.5)
      newSpinner.layer.mask = mask

      frontSpinnerMask = mask
      stateMachine.invalidate(\CollectionViewReloadDelegate.frontSpinner)
    }
  }

  /// Reload control spinner at the end of the collection view.
  var endSpinner: (any CollectionViewSpinner)? {
    willSet {
      guard let oldSpinner = endSpinner else { return }
      oldSpinner.removeFromSuperview()
      endSpinnerMask = nil
    }

    didSet {
      guard let backgroundView = collectionView.backgroundView, let newSpinner = endSpinner else { return }
      backgroundView.addSubview(newSpinner)

      let mask = CAGradientLayer()
      mask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
      mask.startPoint = CGPoint(x: 1.01, y: 0.5)
      mask.endPoint = CGPoint(x: 1.0, y: 0.5)
      newSpinner.layer.mask = mask

      endSpinnerMask = mask
      stateMachine.invalidate(\CollectionViewReloadDelegate.endSpinner)
    }
  }

  /// Gradient mask of the reload control spinner at the end of the collection
  /// view.
  private var frontSpinnerMask: CAGradientLayer?

  /// X constraint of the front spinner.
  private var frontSpinnerConstraintX: NSLayoutConstraint?

  /// Y constraint of the front spinner.
  private var frontSpinnerConstraintY: NSLayoutConstraint?

  /// Gradient mask of the reload control spinner at the end of the collection
  /// view.
  private var endSpinnerMask: CAGradientLayer?

  /// X constraint of the end spinner.
  private var endSpinnerConstraintX: NSLayoutConstraint?

  /// Y constraint of the end spinner.
  private var endSpinnerConstraintY: NSLayoutConstraint?

  /// Distance required to overscroll in order to trigger a reload (consequently
  /// showing the spinner). This value INCLUDES the content insets of the
  /// collection view.
  @Stateful var displacementToTriggerReload: CGFloat = 60.0

  /// Specifies whether user can pull to reload at end of collection (as
  /// opposed to only the front).
  @Stateful var canPullFromEndToReload: Bool = false

  /// Specifies the orientation of the spinners.
  @Stateful var orientation: UICollectionView.ScrollDirection = .vertical

  /// The content insets of the collection view.
  @Stateful var contentInsets: UIEdgeInsets = .zero

  init(
    collectionView: UICollectionView,
    willPullToReload: @escaping () -> Bool = { true },
    didPullToReload: @escaping () -> Void = {}
  ) {
    self.collectionView = collectionView
    self.willPullToReloadHandler = willPullToReload
    self.didPullToReloadHandler = didPullToReload

    collectionView.backgroundView = UIView()
  }

  /// Starts either the front or the end spinners if applicable, depending on
  /// the current scroll position of the collection view.
  func startSpinnersIfNeeded() {
    guard willPullToReloadHandler() else { return }

    var frontDelta: CGFloat = 0.0
    var endDelta: CGFloat = 0.0

    switch orientation {
    case .vertical:
      frontDelta = min(0.0, collectionView.contentOffset.y - collectionView.minContentOffset.y)
      endDelta = max(0.0, collectionView.contentOffset.y - collectionView.maxContentOffset.y)
    default:
      frontDelta = min(0.0, collectionView.contentOffset.x - collectionView.minContentOffset.x)
      endDelta = max(0.0, collectionView.contentOffset.x - collectionView.maxContentOffset.x)
    }

    if frontDelta < -displacementToTriggerReload {
      startFrontSpinner()
    }
    else if canPullFromEndToReload, endDelta > displacementToTriggerReload {
      startEndSpinner()
    }
  }

  /// Stops all active spinners.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion.
  func stopSpinnersIfNeeded(completion: @escaping () -> Void) {
    let group = DispatchGroup()

    group.enter()
    group.enter()

    stopFrontSpinner() { group.leave() }
    stopEndSpinner() { group.leave() }

    group.notify(queue: .main) {
      completion()
    }
  }

  /// Starts the reload control spinner at the front of the collection.
  private func startFrontSpinner() {
    guard
      let frontSpinner = frontSpinner,
      !frontSpinner.isActive,
      endSpinner?.isActive != true,
      willPullToReloadHandler()
    else { return }

    frontSpinner.isActive = true
    frontSpinnerMask?.endPoint = CGPoint(x: 2.0, y: 0.5)

    var insets = contentInsets

    switch orientation {
    case .vertical: insets.top = displacementToTriggerReload
    default: insets.left = displacementToTriggerReload
    }

    // Reload is triggered when the user pulls from the front of the scroll
    // view. When the pull is released, animate the scroll view position so it
    // is parked just beside the front spinner.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = insets
      }, completion: nil)

      var offset = self.collectionView.contentOffset

      switch self.orientation {
      case .vertical:
        offset.y = self.collectionView.minContentOffset.y
      default:
        offset.x = self.collectionView.minContentOffset.x
      }

      self.collectionView.setContentOffset(offset, animated: true)
    }

    didPullToReloadHandler()
  }

  /// Stops the reload control spinner at the front of the collection view.
  ///
  /// - Parameters:
  ///   - completion: Handle invoked upon completion.
  private func stopFrontSpinner(completion: @escaping () -> Void) {
    guard let frontSpinner = frontSpinner, frontSpinner.isActive else {
      completion()
      return
    }

    frontSpinner.isActive = false
    frontSpinnerMask?.endPoint = CGPoint(x: 0.0, y: 0.5)

    // Play collapsing animation in the next UI cycle to avoid choppiness.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = self.contentInsets
      }) { _ in
        completion()
      }
    }
  }

  /// Starts the reload control spinner at the end of the collection.
  private func startEndSpinner() {
    guard
      let endSpinner = endSpinner,
      !endSpinner.isActive,
      frontSpinner?.isActive != true,
      canPullFromEndToReload,
      willPullToReloadHandler()
    else { return }

    endSpinner.isActive = true
    endSpinnerMask?.endPoint = CGPoint(x: -1.0, y: 0.5)

    var insets = contentInsets

    switch orientation {
    case .vertical: insets.bottom = displacementToTriggerReload
    default: insets.right = displacementToTriggerReload
    }

    // Reload is triggered when the user pulls from the end of the scroll view.
    // When the pull is released, animate the scroll view position so it is
    // parked just beside the end spinner.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = insets
      }, completion: nil)

      var offset = self.collectionView.contentOffset

      switch self.orientation {
      case .vertical:
        offset.y = self.collectionView.maxContentOffset.y
      default:
        offset.x = self.collectionView.maxContentOffset.x
      }

      self.collectionView.setContentOffset(offset, animated: true)
    }

    didPullToReloadHandler()
  }

  /// Stops the reload control spinner at the end of the collection view.
  ///
  /// - Parameters:
  ///   - completion: Handle invoked upon completion.
  private func stopEndSpinner(completion: @escaping () -> Void) {
    guard let endSpinner = endSpinner, endSpinner.isActive else {
      completion()
      return
    }

    endSpinner.isActive = false
    endSpinnerMask?.endPoint = CGPoint(x: 1.0, y: 0.5)

    // Play collapsing animation in the next UI cycle to avoid choppiness.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = self.contentInsets
      }) { _ in
        completion()
      }
    }
  }

  func layoutSubviewsIfNeeded() {
    guard willPullToReloadHandler() else { return }

    switch orientation {
    case .vertical:
      // Content offset of scrollview should be < 0
      let frontDelta: CGFloat = min(0.0, collectionView.contentOffset.y - collectionView.minContentOffset.y)
      frontSpinnerMask?.endPoint = CGPoint(x: min(1.0, abs(frontDelta / displacementToTriggerReload)) * 2.0, y: 0.5)

      if canPullFromEndToReload {
        // Content offset of scrollview should be > 0
        let endDelta: CGFloat = max(0.0, collectionView.contentOffset.y - collectionView.maxContentOffset.y)
        endSpinnerMask?.endPoint = CGPoint(x: 1.0 - min(1.0, abs(endDelta / displacementToTriggerReload)) * 2.0, y: 0.5)
      }
    default:
      // Content offset of scrollview should be < 0
      let frontDelta: CGFloat = min(0.0, collectionView.contentOffset.x - collectionView.minContentOffset.x)
      frontSpinnerMask?.endPoint = CGPoint(x: min(1.0, abs(frontDelta / displacementToTriggerReload)) * 2.0, y: 0.5)

      if canPullFromEndToReload {
        // Content offset of scrollview should be > 0
        let endDelta: CGFloat = max(0.0, collectionView.contentOffset.x - collectionView.maxContentOffset.x)
        endSpinnerMask?.endPoint = CGPoint(x: 1.0 - min(1.0, abs(endDelta / displacementToTriggerReload)) * 2.0, y: 0.5)
      }
    }
  }

  func layoutSublayersIfNeeded() {
    if let mask = frontSpinnerMask, let spinner = frontSpinner {
      mask.bounds = spinner.bounds
      mask.frame = spinner.bounds
    }

    if let mask = endSpinnerMask, let spinner = endSpinner {
      mask.bounds = spinner.bounds
      mask.frame = spinner.bounds
    }
  }
}

extension CollectionViewReloadDelegate: StateMachineDelegate {
  func update(check: StateValidator) {
    if check.isDirty(
      \CollectionViewReloadDelegate.orientation,
      \CollectionViewReloadDelegate.contentInsets,
      \CollectionViewReloadDelegate.frontSpinner,
      \CollectionViewReloadDelegate.endSpinner
    ) {
      collectionView.contentInset = contentInsets

      switch orientation {
      case .vertical:
        if let frontSpinner = frontSpinner {
          if let constraintX = frontSpinnerConstraintX { frontSpinner.removeConstraint(constraintX) }
          if let constraintY = frontSpinnerConstraintY { frontSpinner.removeConstraint(constraintY) }

          frontSpinner.autoLayout {
            self.frontSpinnerConstraintX = $0.alignToSuperview(.centerX).first
            self.frontSpinnerConstraintY = $0.align(.centerY, to: frontSpinner.superview!, for: .top, offset: displacementToTriggerReload * 0.5).first
          }
        }

        if let endSpinner = endSpinner {
          if let constraintX = endSpinnerConstraintX { endSpinner.removeConstraint(constraintX) }
          if let constraintY = endSpinnerConstraintY { endSpinner.removeConstraint(constraintY) }

          endSpinner.autoLayout {
            self.endSpinnerConstraintX = $0.alignToSuperview(.centerX).first
            self.endSpinnerConstraintY = $0.align(.centerY, to: endSpinner.superview!, for: .bottom, offset: -displacementToTriggerReload * 0.5).first
          }
        }
      default:
        if let frontSpinner = frontSpinner {
          if let constraintX = frontSpinnerConstraintX { frontSpinner.removeConstraint(constraintX) }
          if let constraintY = frontSpinnerConstraintY { frontSpinner.removeConstraint(constraintY) }

          frontSpinner.autoLayout {
            self.frontSpinnerConstraintX = $0.alignToSuperview(.left, offset: 15.0).first
            self.frontSpinnerConstraintY = $0.alignToSuperview(.centerY).first
          }
        }

        if let endSpinner = endSpinner {
          if let constraintX = endSpinnerConstraintX { endSpinner.removeConstraint(constraintX) }
          if let constraintY = endSpinnerConstraintY { endSpinner.removeConstraint(constraintY) }

          endSpinner.autoLayout {
            self.endSpinnerConstraintX = $0.alignToSuperview(.right, offset: 15.0).first
            self.endSpinnerConstraintY = $0.alignToSuperview(.centerY).first
          }
        }
      }
    }
  }
}
