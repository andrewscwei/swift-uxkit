// © GHOZT

import BaseKit
import UIKit

class CollectionViewRefreshControlDelegate {
  /// Internal `StateMachine` instance.
  lazy var stateMachine = StateMachine(self)

  /// The `UICollectionView` this controller controls.
  private let collectionView: UICollectionView

  /// Handler invoked to determine if pulling to refresh is enabled.
  private let willPullToRefreshHandler: () -> Bool

  /// Handler invoked after pulling to refresh.
  private let didPullToRefreshHandler: () -> Void

  /// Refresh control at the front of the collection view.
  let frontRefreshControl: (any CollectionViewRefreshControl)?

  /// Refresh control at the end of the collection view.
  let endRefreshControl: (any CollectionViewRefreshControl)?

  /// X constraint of the front refresh control.
  private var frontRefreshControlConstraintX: NSLayoutConstraint?

  /// Y constraint of the front refresh control.
  private var frontRefreshControlConstraintY: NSLayoutConstraint?

  /// X constraint of the end refresh control.
  private var endRefreshControlConstraintX: NSLayoutConstraint?

  /// Y constraint of the end refresh control.
  private var endRefreshControlConstraintY: NSLayoutConstraint?

  /// Distance required to overscroll in order to trigger a refresh
  /// (consequently activating the refresh control). This value **includes** the
  /// content insets of the collection view.
  @Stateful var displacementToTriggerRefresh: CGFloat = 60.0

  /// Specifies the orientation of the refresh controls.
  @Stateful var orientation: UICollectionView.ScrollDirection = .vertical

  /// The content insets of the collection view.
  ///
  /// NOTE: Content insets directly affect the minimum content offset. For
  /// example, if `contentInsets.top` is `100`, `collectionView.contentOffset.y`
  /// will be `-100`.
  @Stateful var contentInsets: UIEdgeInsets = .zero

  init(
    collectionView: UICollectionView,
    frontRefreshControl: (any CollectionViewRefreshControl)?,
    endRefreshControl: (any CollectionViewRefreshControl)?,
    willPullToRefresh: @escaping () -> Bool = { true },
    didPullToRefresh: @escaping () -> Void = {}
  ) {
    self.collectionView = collectionView
    self.frontRefreshControl = frontRefreshControl
    self.endRefreshControl = endRefreshControl
    self.willPullToRefreshHandler = willPullToRefresh
    self.didPullToRefreshHandler = didPullToRefresh

    addFrontRefreshControlToSuperView()
    addEndRefreshControlToSuperView()
  }

  /// Starts either the front or the end refresh control if applicable,
  /// depending on the current scroll position of the collection view.
  func activateRefreshControlsIfNeeded() {
    guard willPullToRefreshHandler() else { return }

    var frontDelta: CGFloat = 0
    var endDelta: CGFloat = 0

    switch orientation {
    case .vertical:
      frontDelta = min(0, collectionView.contentOffset.y - collectionView.minContentOffset.y)
      endDelta = max(0, collectionView.contentOffset.y - collectionView.maxContentOffset.y)
    default:
      frontDelta = min(0, collectionView.contentOffset.x - collectionView.minContentOffset.x)
      endDelta = max(0, collectionView.contentOffset.x - collectionView.maxContentOffset.x)
    }

    if frontDelta < -displacementToTriggerRefresh {
      activateRefreshControl()
    }
    else if endDelta > displacementToTriggerRefresh {
      activateEndRefreshControl()
    }
  }

  /// Stops all active refresh controls.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion.
  func deactivateRefreshControlsIfNeeded(completion: @escaping () -> Void) {
    let group = DispatchGroup()

    group.enter()
    group.enter()

    stopFrontRefreshControl() { group.leave() }
    stopEndRefreshControl() { group.leave() }

    group.notify(queue: .main) {
      completion()
    }
  }

  private func activateRefreshControl() {
    guard let control = frontRefreshControl, !control.isActive, endRefreshControl?.isActive != true, willPullToRefreshHandler() else { return }

    control.isActive = true
    (control.layer.mask as? CAGradientLayer)?.colors = [UIColor.black.withAlphaComponent(1.0).cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]

    var insets = contentInsets

    switch orientation {
    case .horizontal: insets.left = insets.left + displacementToTriggerRefresh
    default: insets.top = insets.top + displacementToTriggerRefresh
    }

    // Refresh is triggered when the user pulls from the front of the scroll
    // view. When the pull is released, animate the scroll view position so it
    // is parked just by the front refresh control.
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

    didPullToRefreshHandler()
  }

  private func stopFrontRefreshControl(completion: @escaping () -> Void) {
    guard let control = frontRefreshControl, control.isActive else {
      completion()
      return
    }

    control.isActive = false
    (control.layer.mask as? CAGradientLayer)?.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor]

    // Play collapsing animation in the next UI cycle to avoid choppiness.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = self.contentInsets
      }) { _ in
        completion()
      }
    }
  }

  private func activateEndRefreshControl() {
    guard let control = endRefreshControl, !control.isActive, frontRefreshControl?.isActive != true, willPullToRefreshHandler() else { return }

    control.isActive = true
    (control.layer.mask as? CAGradientLayer)?.colors = [UIColor.black.withAlphaComponent(1.0).cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]

    var insets = contentInsets

    switch orientation {
    case .horizontal: insets.right = insets.right + displacementToTriggerRefresh
    default: insets.bottom = insets.bottom + displacementToTriggerRefresh
    }

    // Refresh is triggered when the user pulls from the end of the scroll view.
    // When the pull is released, animate the scroll view position so it is
    // parked just by the end refresh control.
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

    didPullToRefreshHandler()
  }

  private func stopEndRefreshControl(completion: @escaping () -> Void) {
    guard let control = endRefreshControl, control.isActive else { return completion() }

    control.isActive = false
    (control.layer.mask as? CAGradientLayer)?.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor]

    // Play collapsing animation in the next UI cycle to avoid choppiness.
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.2, animations: {
        self.collectionView.contentInset = self.contentInsets
      }) { _ in
        completion()
      }
    }
  }

  private func removeFrontRefreshControlFromSuperView() {
    guard let control = frontRefreshControl else { return }
    control.removeFromSuperview()
  }

  private func addFrontRefreshControlToSuperView() {
    guard let control = frontRefreshControl else { return }

    collectionView.superview?.insertSubview(control, belowSubview: collectionView)

    let mask = CAGradientLayer()
    mask.bounds = control.bounds
    mask.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
    mask.endPoint = CGPoint(x: 1.0, y: 0.5)
    mask.frame = control.bounds
    mask.startPoint = CGPoint(x: 0, y: 0.5)
    control.layer.mask = mask

    stateMachine.invalidate(\CollectionViewRefreshControlDelegate.frontRefreshControl)
  }

  private func removeEndRefreshControlFromSuperView() {
    guard let control = endRefreshControl else { return }
    control.removeFromSuperview()
  }

  private func addEndRefreshControlToSuperView() {
    guard let control = endRefreshControl else { return }

    collectionView.superview?.insertSubview(control, belowSubview: collectionView)

    let mask = CAGradientLayer()
    mask.bounds = control.bounds
    mask.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
    mask.endPoint = CGPoint(x: 1.0, y: 0.5)
    mask.frame = control.bounds
    mask.startPoint = CGPoint(x: 0, y: 0.5)
    control.layer.mask = mask

    stateMachine.invalidate(\CollectionViewRefreshControlDelegate.endRefreshControl)
  }
}

extension CollectionViewRefreshControlDelegate: StateMachineDelegate {
  func update(check: StateValidator) {
    if check.isDirty(\CollectionViewRefreshControlDelegate.contentInsets) {
      collectionView.contentInset = contentInsets
    }

    if check.isDirty(\CollectionViewRefreshControlDelegate.frontRefreshControl, \CollectionViewRefreshControlDelegate.orientation, \CollectionViewRefreshControlDelegate.displacementToTriggerRefresh) {
      if let frontRefreshControl = frontRefreshControl {
        switch orientation {
        case .vertical:
          if let constraintX = frontRefreshControlConstraintX { frontRefreshControl.removeConstraint(constraintX) }
          if let constraintY = frontRefreshControlConstraintY { frontRefreshControl.removeConstraint(constraintY) }

          frontRefreshControl.autoLayout {
            self.frontRefreshControlConstraintX = $0.alignToSuperview(.centerX).first
            self.frontRefreshControlConstraintY = $0.align(.centerY, to: collectionView, for: .top, offset: displacementToTriggerRefresh * 0.5).first
          }
        default:
          if let constraintX = frontRefreshControlConstraintX { frontRefreshControl.removeConstraint(constraintX) }
          if let constraintY = frontRefreshControlConstraintY { frontRefreshControl.removeConstraint(constraintY) }

          frontRefreshControl.autoLayout {
            self.frontRefreshControlConstraintX = $0.alignToSuperview(.left, offset: 15.0).first
            self.frontRefreshControlConstraintY = $0.alignToSuperview(.centerY).first
          }
        }
      }
    }

    if check.isDirty(\CollectionViewRefreshControlDelegate.endRefreshControl, \CollectionViewRefreshControlDelegate.orientation, \CollectionViewRefreshControlDelegate.displacementToTriggerRefresh) {
      if let endRefreshControl = endRefreshControl {
        switch orientation {
        case .vertical:
          if let constraintX = endRefreshControlConstraintX { endRefreshControl.removeConstraint(constraintX) }
          if let constraintY = endRefreshControlConstraintY { endRefreshControl.removeConstraint(constraintY) }

          endRefreshControl.autoLayout {
            self.endRefreshControlConstraintX = $0.alignToSuperview(.centerX).first
            self.endRefreshControlConstraintY = $0.align(.centerY, to: collectionView, for: .bottom, offset: -displacementToTriggerRefresh * 0.5).first
          }
        default:
          if let constraintX = endRefreshControlConstraintX { endRefreshControl.removeConstraint(constraintX) }
          if let constraintY = endRefreshControlConstraintY { endRefreshControl.removeConstraint(constraintY) }

          endRefreshControl.autoLayout {
            self.endRefreshControlConstraintX = $0.alignToSuperview(.right, offset: 15.0).first
            self.endRefreshControlConstraintY = $0.alignToSuperview(.centerY).first
          }
        }
      }
    }
  }

  /// Reveals the refresh controls depending on the current content offset of
  /// the collection view.
  func layoutRefreshControlsIfNeeded() {
    guard willPullToRefreshHandler() else { return }

    if frontRefreshControl?.isActive != true, let mask = frontRefreshControl?.layer.mask as? CAGradientLayer {
      let currentOffset = orientation == .vertical ? collectionView.contentOffset.y : collectionView.contentOffset.x
      let minOffset = orientation == .vertical ? collectionView.minContentOffset.y : collectionView.minContentOffset.x

      if currentOffset <= minOffset - displacementToTriggerRefresh {
        mask.colors = [UIColor.black.withAlphaComponent(1.0).cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]
      }
      else {
        let delta = abs(min(0, currentOffset - minOffset))
        let alpha0 = max(0, min(1.0, delta / (displacementToTriggerRefresh * 0.5)))
        let alpha1 = max(0, min(1.0, (delta - displacementToTriggerRefresh * 0.5) / (displacementToTriggerRefresh * 0.5)))
        mask.colors = [UIColor.black.withAlphaComponent(alpha0).cgColor, UIColor.black.withAlphaComponent(alpha1).cgColor]
      }
    }

    if endRefreshControl?.isActive != true, let mask = endRefreshControl?.layer.mask as? CAGradientLayer {
      let currentOffset = orientation == .vertical ? collectionView.contentOffset.y : collectionView.contentOffset.x
      let maxOffset = orientation == .vertical ? collectionView.maxContentOffset.y : collectionView.maxContentOffset.x

      if currentOffset >= maxOffset + displacementToTriggerRefresh {
        mask.colors = [UIColor.black.withAlphaComponent(1.0).cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]
      }
      else {
        let delta = abs(max(0, currentOffset - maxOffset))
        let alpha0 = max(0, min(1.0, delta / (displacementToTriggerRefresh * 0.5)))
        let alpha1 = max(0, min(1.0, (delta - displacementToTriggerRefresh * 0.5) / (displacementToTriggerRefresh * 0.5)))
        mask.colors = [UIColor.black.withAlphaComponent(alpha0).cgColor, UIColor.black.withAlphaComponent(alpha1).cgColor]
      }
    }
  }
}
