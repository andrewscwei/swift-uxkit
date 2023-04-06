// © GHOZT

import BaseKit
import UIKit

/// An object that iteratively applies auto layout rules to a `UIView` instance.
public class AutoLayoutIterator {

  let view: UIView

  init(_ view: UIView) {
    self.view = view

    if !(view is UICollectionViewCell), !(view is UICollectionReusableView) {
      view.translatesAutoresizingMaskIntoConstraints = false
    }
  }

  @discardableResult public func alignToSuperview(
    _ anchorType: AutoLayoutAnchorType = [.top, .right, .bottom, .left],
    offset: CGFloat = 0,
    relation: AutoLayoutRelation = .equalTo,
    guide: AutoLayoutGuide = .none
  ) -> [NSLayoutConstraint] {
    guard let superview = view.superview else { return [] }
    return align(anchorType, to: superview, offset: offset, relation: relation, guide: guide)
  }

  @discardableResult public func alignToSuperview(
    edgeInsets: UIEdgeInsets,
    relation: AutoLayoutRelation = .equalTo,
    guide: AutoLayoutGuide = .none
  ) -> [NSLayoutConstraint] {
    guard
      let superview = view.superview,
      let constraintTop = align(.top, to: superview, offset: edgeInsets.top, relation: relation, guide: guide).first,
      let constraintRight = align(.right, to: superview, offset: edgeInsets.right, relation: relation, guide: guide).first,
      let constraintBottom = align(.bottom, to: superview, offset: edgeInsets.bottom, relation: relation, guide: guide).first,
      let constraintLeft = align(.left, to: superview, offset: edgeInsets.left, relation: relation, guide: guide).first
    else {
      return []
    }

    return [constraintTop, constraintRight, constraintBottom, constraintLeft]
  }

  @discardableResult public func align(
    _ anchorType: AutoLayoutAnchorType = [.top, .right, .bottom, .left],
    to toView: UIView,
    offset: CGFloat = 0,
    relation: AutoLayoutRelation = .equalTo,
    guide: AutoLayoutGuide = .none
  ) -> [NSLayoutConstraint] {
    return align(anchorType, to: toView, for: anchorType, offset: offset, relation: relation, guide: guide)
  }

  @discardableResult public func align(
    _ anchorType: AutoLayoutAnchorType,
    to toView: UIView,
    for toAnchorType: AutoLayoutAnchorType,
    offset: CGFloat = 0,
    relation: AutoLayoutRelation = .equalTo,
    guide: AutoLayoutGuide = .none
  ) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    if anchorType.contains(.top) {
      let anchor: NSLayoutYAxisAnchor?

      if toAnchorType.contains(.top) { anchor = getTopAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.bottom) { anchor = getBottomAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.centerY) { anchor = getCenterYAnchor(of: toView, guide: guide) }
      else { anchor = nil }

      if let anchor = anchor {
        constraints.append(createConstraint(fromAnchor: view.topAnchor, toAnchor: anchor, constant: offset, relation: relation))
      }
    }

    if anchorType.contains(.right) {
      let anchor: NSLayoutXAxisAnchor?

      if toAnchorType.contains(.right) { anchor = getRightAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.left) { anchor = getLeftAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.centerX) { anchor = getCenterXAnchor(of: toView, guide: guide) }
      else { anchor = nil }

      if let anchor = anchor {
        constraints.append(createConstraint(fromAnchor: view.rightAnchor, toAnchor: anchor, constant: -offset, relation: relation))
      }
    }

    if anchorType.contains(.bottom) {
      let anchor: NSLayoutYAxisAnchor?

      if toAnchorType.contains(.bottom) { anchor = getBottomAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.top) { anchor = getTopAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.centerY) { anchor = getCenterYAnchor(of: toView, guide: guide) }
      else { anchor = nil }

      if let anchor = anchor {
        constraints.append(createConstraint(fromAnchor: view.bottomAnchor, toAnchor: anchor, constant: -offset, relation: relation))
      }
    }

    if anchorType.contains(.left) {
      let anchor: NSLayoutXAxisAnchor?

      if toAnchorType.contains(.left) { anchor = getLeftAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.right) { anchor = getRightAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.centerX) { anchor = getCenterXAnchor(of: toView, guide: guide) }
      else { anchor = nil }

      if let anchor = anchor {
        constraints.append(createConstraint(fromAnchor: view.leftAnchor, toAnchor: anchor, constant: offset, relation: relation))
      }
    }

    if anchorType.contains(.centerX) {
      let anchor: NSLayoutXAxisAnchor?

      if toAnchorType.contains(.centerX) { anchor = getCenterXAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.left) { anchor = getLeftAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.right) { anchor = getRightAnchor(of: toView, guide: guide) }
      else { anchor = nil }

      if let anchor = anchor {
        constraints.append(createConstraint(fromAnchor: view.centerXAnchor, toAnchor: anchor, constant: offset, relation: relation))
      }
    }

    if anchorType.contains(.centerY) {
      let anchor: NSLayoutYAxisAnchor?

      if toAnchorType.contains(.centerY) { anchor = getCenterYAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.top) { anchor = getTopAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.bottom) { anchor = getBottomAnchor(of: toView, guide: guide) }
      else { anchor = nil }

      if let anchor = anchor {
        constraints.append(createConstraint(fromAnchor: view.centerYAnchor, toAnchor: anchor, constant: offset, relation: relation))
      }
    }

    if anchorType.contains(.width) {
      let anchor: NSLayoutDimension?

      if toAnchorType.contains(.width) { anchor = getWidthAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.height) { anchor = getHeightAnchor(of: toView, guide: guide) }
      else { anchor = nil }

      if let anchor = anchor {
        constraints.append(createConstraint(fromAnchor: view.widthAnchor, toAnchor: anchor, constant: offset, relation: relation))
      }
    }

    if anchorType.contains(.height) {
      let anchor: NSLayoutDimension?

      if toAnchorType.contains(.height) { anchor = getHeightAnchor(of: toView, guide: guide) }
      else if toAnchorType.contains(.width) { anchor = getWidthAnchor(of: toView, guide: guide) }
      else { anchor = nil }

      if let anchor = anchor {
        constraints.append(createConstraint(fromAnchor: view.heightAnchor, toAnchor: anchor, constant: offset, relation: relation))
      }
    }

    return constraints
  }

  @discardableResult public func fitDimensionToSuperview(
    _ anchorType: AutoLayoutAnchorType = [.width, .height],
    multiplier: CGFloat = 1.0,
    offset: CGFloat = 0,
    relation: AutoLayoutRelation = .equalTo,
    guide: AutoLayoutGuide = .none
  ) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    guard let superview = view.superview else { return constraints }

    if anchorType.contains(.width) {
      let anchor = getWidthAnchor(of: superview, guide: guide)
      let constraint: NSLayoutConstraint

      switch relation {
      case .greaterThanOrEqualTo:
        constraint = view.widthAnchor.constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: offset)
      case .lessThanOrEqualTo:
        constraint = view.widthAnchor.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: offset)
      case .equalTo:
        constraint = view.widthAnchor.constraint(equalTo: anchor, multiplier: multiplier, constant: offset)
      }

      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.height) {
      let anchor = getHeightAnchor(of: superview, guide: guide)
      let constraint: NSLayoutConstraint

      switch relation {
      case .greaterThanOrEqualTo:
        constraint = view.heightAnchor.constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: offset)
      case .lessThanOrEqualTo:
        constraint = view.heightAnchor.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: offset)
      case .equalTo:
        constraint = view.heightAnchor.constraint(equalTo: anchor, multiplier: multiplier, constant: offset)
      }

      constraint.isActive = true
      constraints.append(constraint)
    }

    return constraints
  }

  @discardableResult public func width(_ constant: CGFloat, relation: AutoLayoutRelation = .equalTo) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint

    switch relation {
    case .greaterThanOrEqualTo:
      constraint = view.widthAnchor.constraint(greaterThanOrEqualToConstant: constant)
    case .lessThanOrEqualTo:
      constraint = view.widthAnchor.constraint(lessThanOrEqualToConstant: constant)
    case .equalTo:
      constraint = view.widthAnchor.constraint(equalToConstant: constant)
    }

    constraint.isActive = true
    return constraint
  }

  @discardableResult public func height(_ constant: CGFloat, relation: AutoLayoutRelation = .equalTo) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint

    switch relation {
    case .greaterThanOrEqualTo:
      constraint = view.heightAnchor.constraint(greaterThanOrEqualToConstant: constant)
    case .lessThanOrEqualTo:
      constraint = view.heightAnchor.constraint(lessThanOrEqualToConstant: constant)
    case .equalTo:
      constraint = view.heightAnchor.constraint(equalToConstant: constant)
    }

    constraint.isActive = true
    return constraint
  }

  @discardableResult public func aspectRatio(_ constant: CGFloat = 1.0) -> NSLayoutConstraint {
    let constraint = view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: constant)
    constraint.isActive = true
    return constraint
  }

  @discardableResult public func horizontalSpacing(
    to toView: UIView,
    spacing: CGFloat = 0,
    relation: AutoLayoutRelation = .equalTo,
    guide: AutoLayoutGuide = .none
  ) -> NSLayoutConstraint {
    let anchor = getRightAnchor(of: view, guide: guide)
    return createConstraint(fromAnchor: toView.leftAnchor, toAnchor: anchor, constant: spacing, relation: relation)
  }

  @discardableResult public func horizontalSpacing(
    from fromView: UIView,
    spacing: CGFloat = 0,
    relation: AutoLayoutRelation = .equalTo,
    guide: AutoLayoutGuide = .none
  ) -> NSLayoutConstraint {
    let anchor = getLeftAnchor(of: view, guide: guide)
    return createConstraint(fromAnchor: fromView.rightAnchor, toAnchor: anchor, constant: -spacing, relation: relation)
  }

  @discardableResult public func verticalSpacing(
    to toView: UIView,
    spacing: CGFloat = 0,
    relation: AutoLayoutRelation = .equalTo,
    guide: AutoLayoutGuide = .none
  ) -> NSLayoutConstraint {
    let anchor = getBottomAnchor(of: view, guide: guide)
    return createConstraint(fromAnchor: toView.topAnchor, toAnchor: anchor, constant: spacing, relation: relation)
  }

  @discardableResult public func verticalSpacing(
    from fromView: UIView,
    spacing: CGFloat = 0,
    relation: AutoLayoutRelation = .equalTo,
    guide: AutoLayoutGuide = .none
  ) -> NSLayoutConstraint {
    let anchor = getTopAnchor(of: view, guide: guide)
    return createConstraint(fromAnchor: fromView.bottomAnchor, toAnchor: anchor, constant: -spacing, relation: relation)
  }

  private func getTopAnchor(of view: UIView, guide: AutoLayoutGuide) -> NSLayoutYAxisAnchor {
    switch guide {
    case .layoutMargins: return view.layoutMarginsGuide.topAnchor
    case .safeArea: return view.safeAreaLayoutGuide.topAnchor
    case .none: return view.topAnchor
    }
  }

  private func getRightAnchor(of view: UIView, guide: AutoLayoutGuide) -> NSLayoutXAxisAnchor {
    switch guide {
    case .layoutMargins: return view.layoutMarginsGuide.rightAnchor
    case .safeArea: return view.safeAreaLayoutGuide.rightAnchor
    case .none: return view.rightAnchor
    }
  }

  private func getBottomAnchor(of view: UIView, guide: AutoLayoutGuide) -> NSLayoutYAxisAnchor {
    switch guide {
    case .layoutMargins: return view.layoutMarginsGuide.bottomAnchor
    case .safeArea: return view.safeAreaLayoutGuide.bottomAnchor
    case .none: return view.bottomAnchor
    }
  }

  private func getLeftAnchor(of view: UIView, guide: AutoLayoutGuide) -> NSLayoutXAxisAnchor {
    switch guide {
    case .layoutMargins: return view.layoutMarginsGuide.leftAnchor
    case .safeArea: return view.safeAreaLayoutGuide.leftAnchor
    case .none: return view.leftAnchor
    }
  }

  private func getCenterXAnchor(of view: UIView, guide: AutoLayoutGuide) -> NSLayoutXAxisAnchor {
    switch guide {
    case .layoutMargins: return view.layoutMarginsGuide.centerXAnchor
    case .safeArea: return view.safeAreaLayoutGuide.centerXAnchor
    case .none: return view.centerXAnchor
    }
  }

  private func getCenterYAnchor(of view: UIView, guide: AutoLayoutGuide) -> NSLayoutYAxisAnchor {
    switch guide {
    case .layoutMargins: return view.layoutMarginsGuide.centerYAnchor
    case .safeArea: return view.safeAreaLayoutGuide.centerYAnchor
    case .none: return view.centerYAnchor
    }
  }

  private func getWidthAnchor(of view: UIView, guide: AutoLayoutGuide) -> NSLayoutDimension {
    switch guide {
    case .layoutMargins: return view.layoutMarginsGuide.widthAnchor
    case .safeArea: return view.safeAreaLayoutGuide.widthAnchor
    case .none: return view.widthAnchor
    }
  }

  private func getHeightAnchor(of view: UIView, guide: AutoLayoutGuide) -> NSLayoutDimension {
    switch guide {
    case .layoutMargins: return view.layoutMarginsGuide.heightAnchor
    case .safeArea: return view.safeAreaLayoutGuide.heightAnchor
    case .none: return view.heightAnchor
    }
  }

  private func createConstraint<T: AnyObject>(fromAnchor: NSLayoutAnchor<T>, toAnchor: NSLayoutAnchor<T>, constant: CGFloat, relation: AutoLayoutRelation) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint

    switch relation {
    case .greaterThanOrEqualTo: constraint = fromAnchor.constraint(greaterThanOrEqualTo: toAnchor, constant: constant)
    case .lessThanOrEqualTo: constraint = fromAnchor.constraint(lessThanOrEqualTo: toAnchor, constant: constant)
    case .equalTo: constraint = fromAnchor.constraint(equalTo: toAnchor, constant: constant)
    }

    constraint.isActive = true

    return constraint
  }
}
