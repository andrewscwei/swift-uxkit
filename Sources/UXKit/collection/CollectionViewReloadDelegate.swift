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
  private let frontSpinner: (any CollectionViewSpinner)?

  /// Reload control spinner at the end of the collection view.
  private let endSpinner: (any CollectionViewSpinner)?

  /// X constraint of the front spinner.
  private var frontSpinnerConstraintX: NSLayoutConstraint?

  /// Y constraint of the front spinner.
  private var frontSpinnerConstraintY: NSLayoutConstraint?

  /// X constraint of the end spinner.
  private var endSpinnerConstraintX: NSLayoutConstraint?

  /// Y constraint of the end spinner.
  private var endSpinnerConstraintY: NSLayoutConstraint?

  /// Distance required to overscroll in order to trigger a reload (consequently
  /// showing the spinner). This value INCLUDES the content insets of the
  /// collection view.
  @Stateful var displacementToTriggerReload: CGFloat = 60.0

  /// Specifies the orientation of the spinners.
  @Stateful var orientation: UICollectionView.ScrollDirection = .vertical

  /// The content insets of the collection view.
  ///
  /// NOTE: Content insets directly affect the minimum content offset. For
  /// example, if `contentInsets.top` is `100`, `collectionView.contentOffset.y`
  /// will be `-100`.
  @Stateful var contentInsets: UIEdgeInsets = .zero

  init(
    collectionView: UICollectionView,
    frontSpinner: (any CollectionViewSpinner)?,
    endSpinner: (any CollectionViewSpinner)?,
    willPullToReload: @escaping () -> Bool = { true },
    didPullToReload: @escaping () -> Void = {}
  ) {
    self.collectionView = collectionView
    self.frontSpinner = frontSpinner
    self.endSpinner = endSpinner
    self.willPullToReloadHandler = willPullToReload
    self.didPullToReloadHandler = didPullToReload

    addFrontSpinnerToSuperView()
    addEndSpinnerToSuperView()
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
    else if endDelta > displacementToTriggerReload {
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

  private func startFrontSpinner() {
    guard let spinner = frontSpinner, !spinner.isActive, endSpinner?.isActive != true, willPullToReloadHandler() else { return }

    spinner.isActive = true
    (spinner.layer.mask as? CAGradientLayer)?.colors = [UIColor.black.withAlphaComponent(1.0).cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]

    var insets = contentInsets

    switch orientation {
    case .horizontal: insets.left = insets.left + displacementToTriggerReload
    default: insets.top = insets.top + displacementToTriggerReload
    }

    // Reload is triggered when the user pulls from the front of the scroll
    // view. When the pull is released, animate the scroll view position so it
    // is parked just by the front spinner.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = insets
      }, completion: nil)

      var offset = self.collectionView.contentOffset

      switch self.orientation {
      case .horizontal: offset.x = self.collectionView.minContentOffset.x
      default: offset.y = self.collectionView.minContentOffset.y
      }

      self.collectionView.setContentOffset(offset, animated: true)
    }

    didPullToReloadHandler()
  }

  private func stopFrontSpinner(completion: @escaping () -> Void) {
    guard let spinner = frontSpinner, spinner.isActive else {
      completion()
      return
    }

    spinner.isActive = false
    (spinner.layer.mask as? CAGradientLayer)?.colors = [UIColor.black.withAlphaComponent(0.0).cgColor, UIColor.black.withAlphaComponent(0.0).cgColor]

    // Play collapsing animation in the next UI cycle to avoid choppiness.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = self.contentInsets
      }) { _ in
        completion()
      }
    }
  }

  private func startEndSpinner() {
    guard let spinner = endSpinner, !spinner.isActive, frontSpinner?.isActive != true, willPullToReloadHandler() else { return }

    spinner.isActive = true
    (spinner.layer.mask as? CAGradientLayer)?.colors = [UIColor.black.withAlphaComponent(1.0).cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]

    var insets = contentInsets

    switch orientation {
    case .horizontal: insets.right = insets.right + displacementToTriggerReload
    default: insets.bottom = insets.bottom + displacementToTriggerReload
    }

    // Reload is triggered when the user pulls from the end of the scroll view.
    // When the pull is released, animate the scroll view position so it is
    // parked just by the end spinner.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = insets
      }, completion: nil)

      var offset = self.collectionView.contentOffset

      switch self.orientation {
      case .horizontal: offset.x = self.collectionView.maxContentOffset.x
      default: offset.y = self.collectionView.maxContentOffset.y
      }

      self.collectionView.setContentOffset(offset, animated: true)
    }

    didPullToReloadHandler()
  }

  private func stopEndSpinner(completion: @escaping () -> Void) {
    guard let spinner = endSpinner, spinner.isActive else { return completion() }

    spinner.isActive = false
    (spinner.layer.mask as? CAGradientLayer)?.colors = [UIColor.black.withAlphaComponent(0.0).cgColor, UIColor.black.withAlphaComponent(0.0).cgColor]

    // Play collapsing animation in the next UI cycle to avoid choppiness.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = self.contentInsets
      }) { _ in
        completion()
      }
    }
  }

  private func removeFrontSpinnerFromSuperView() {
    guard let spinner = frontSpinner else { return }
    spinner.removeFromSuperview()
  }

  private func addFrontSpinnerToSuperView() {
    guard let spinner = frontSpinner else { return }

    collectionView.superview?.insertSubview(spinner, belowSubview: collectionView)

    let mask = CAGradientLayer()
    mask.bounds = spinner.bounds
    mask.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
    mask.endPoint = CGPoint(x: 1.0, y: 0.5)
    mask.frame = spinner.bounds
    mask.startPoint = CGPoint(x: 0.0, y: 0.5)
    spinner.layer.mask = mask

    stateMachine.invalidate(\CollectionViewReloadDelegate.frontSpinner)
  }

  private func removeEndSpinnerFromSuperView() {
    guard let spinner = endSpinner else { return }
    spinner.removeFromSuperview()
  }

  private func addEndSpinnerToSuperView() {
    guard let spinner = endSpinner else { return }

    collectionView.superview?.insertSubview(spinner, belowSubview: collectionView)

    let mask = CAGradientLayer()
    mask.bounds = spinner.bounds
    mask.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
    mask.endPoint = CGPoint(x: 1.0, y: 0.5)
    mask.frame = spinner.bounds
    mask.startPoint = CGPoint(x: 0.0, y: 0.5)
    spinner.layer.mask = mask

    stateMachine.invalidate(\CollectionViewReloadDelegate.endSpinner)
  }
}

extension CollectionViewReloadDelegate: StateMachineDelegate {
  func update(check: StateValidator) {
    if check.isDirty(\CollectionViewReloadDelegate.contentInsets) {
      collectionView.contentInset = contentInsets
    }

    if check.isDirty(\CollectionViewReloadDelegate.frontSpinner, \CollectionViewReloadDelegate.orientation, \CollectionViewReloadDelegate.displacementToTriggerReload) {
      if let frontSpinner = frontSpinner {
        switch orientation {
        case .vertical:
          if let constraintX = frontSpinnerConstraintX { frontSpinner.removeConstraint(constraintX) }
          if let constraintY = frontSpinnerConstraintY { frontSpinner.removeConstraint(constraintY) }

          frontSpinner.autoLayout {
            self.frontSpinnerConstraintX = $0.alignToSuperview(.centerX).first
            self.frontSpinnerConstraintY = $0.align(.centerY, to: collectionView, for: .top, offset: displacementToTriggerReload * 0.5).first
          }
        default:
          if let constraintX = frontSpinnerConstraintX { frontSpinner.removeConstraint(constraintX) }
          if let constraintY = frontSpinnerConstraintY { frontSpinner.removeConstraint(constraintY) }

          frontSpinner.autoLayout {
            self.frontSpinnerConstraintX = $0.alignToSuperview(.left, offset: 15.0).first
            self.frontSpinnerConstraintY = $0.alignToSuperview(.centerY).first
          }
        }
      }
    }

    if check.isDirty(\CollectionViewReloadDelegate.endSpinner, \CollectionViewReloadDelegate.orientation, \CollectionViewReloadDelegate.displacementToTriggerReload) {
      if let endSpinner = endSpinner {
        switch orientation {
        case .vertical:
          if let constraintX = endSpinnerConstraintX { endSpinner.removeConstraint(constraintX) }
          if let constraintY = endSpinnerConstraintY { endSpinner.removeConstraint(constraintY) }

          endSpinner.autoLayout {
            self.endSpinnerConstraintX = $0.alignToSuperview(.centerX).first
            self.endSpinnerConstraintY = $0.align(.centerY, to: collectionView, for: .bottom, offset: -displacementToTriggerReload * 0.5).first
          }
        default:
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

  /// Reveals the spinners depending on the current content offset of the
  /// collection view.
  func layoutSpinnersIfNeeded() {
    guard willPullToReloadHandler() else { return }

    if frontSpinner?.isActive != true, let mask = frontSpinner?.layer.mask as? CAGradientLayer {
      let offset = orientation == .vertical ? collectionView.contentOffset.y : collectionView.contentOffset.x
      let minOffset = orientation == .vertical ? -(displacementToTriggerReload + contentInsets.top) : -(displacementToTriggerReload + contentInsets.left)

      if offset <= minOffset {
        mask.colors = [UIColor.black.withAlphaComponent(1.0).cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]
      }
      else {
        let delta = abs(min(0.0, orientation == .vertical ? collectionView.contentOffset.y - collectionView.minContentOffset.y : collectionView.contentOffset.x - collectionView.minContentOffset.x))
        let alpha0 = max(0.0, min(1.0, delta / (displacementToTriggerReload * 0.5)))
        let alpha1 = max(0.0, min(1.0, (delta - displacementToTriggerReload * 0.5) / (displacementToTriggerReload * 0.5)))
        mask.colors = [UIColor.black.withAlphaComponent(alpha0).cgColor, UIColor.black.withAlphaComponent(alpha1).cgColor]
      }
    }

    if endSpinner?.isActive != true, let mask = endSpinner?.layer.mask as? CAGradientLayer {
      let offset = orientation == .vertical ? collectionView.contentOffset.y : collectionView.contentOffset.x
      let maxOffset = orientation == .vertical ? displacementToTriggerReload + contentInsets.bottom : displacementToTriggerReload + contentInsets.right

      if offset >= maxOffset {
        mask.colors = [UIColor.black.withAlphaComponent(1.0).cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]
      }
      else {
        let delta = abs(max(0.0, orientation == .vertical ? collectionView.contentOffset.y - collectionView.maxContentOffset.y : collectionView.contentOffset.x - collectionView.maxContentOffset.x))
        let alpha0 = max(0.0, min(1.0, delta / (displacementToTriggerReload * 0.5)))
        let alpha1 = max(0.0, min(1.0, (delta - displacementToTriggerReload * 0.5) / (displacementToTriggerReload * 0.5)))
        mask.colors = [UIColor.black.withAlphaComponent(alpha0).cgColor, UIColor.black.withAlphaComponent(alpha1).cgColor]
      }
    }
  }
}
