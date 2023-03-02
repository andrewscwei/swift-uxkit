// © GHOZT

import BaseKit
import UIKit

/// An object that iteratively applies auto layout rules to a `UIView` instance.
public class AutoLayoutIterator {

  let view: UIView

  init(_ view: UIView) {
    self.view = view

    if !(view is UICollectionViewCell) {
      view.translatesAutoresizingMaskIntoConstraints = false
    }
  }

  @discardableResult public func alignToSuperview(_ anchorType: AutoLayoutAnchorType = [.top, .right, .bottom, .left], offset: CGFloat = 0.0, useSafeArea: Bool = false) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    guard let superview = view.superview else { return constraints }

    if anchorType.contains(.top) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.topAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor, constant: offset)
      }
      else {
        constraint = view.topAnchor.constraint(equalTo: superview.topAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.right) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.rightAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.rightAnchor : superview.rightAnchor, constant: -offset)
      }
      else {
        constraint = view.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.bottom) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.bottomAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor, constant: -offset)
      }
      else {
        constraint = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.left) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.leftAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.leftAnchor : superview.leftAnchor, constant: offset)
      }
      else {
        constraint = view.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.centerX) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.centerXAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.centerXAnchor : superview.centerXAnchor, constant: offset)
      }
      else {
        constraint = view.centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.centerY) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.centerYAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.centerYAnchor : superview.centerYAnchor, constant: offset)
      }
      else {
        constraint = view.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.width) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.widthAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.widthAnchor : superview.widthAnchor, constant: offset)
      }
      else {
        constraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.height) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.heightAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.heightAnchor : superview.heightAnchor, constant: offset)
      }
      else {
        constraint = view.heightAnchor.constraint(equalTo: superview.heightAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    return constraints
  }

  @discardableResult public func alignToSuperview(edgeInsets: UIEdgeInsets, useSafeArea: Bool = false) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    guard let superview = view.superview else { return constraints }

    var constraint: NSLayoutConstraint

    if #available(iOS 11.0, *) {
      constraint = view.topAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor, constant: edgeInsets.top)
    }
    else {
      constraint = view.topAnchor.constraint(equalTo: superview.topAnchor, constant: edgeInsets.top)
    }
    constraint.isActive = true
    constraints.append(constraint)

    if #available(iOS 11.0, *) {
      constraint = view.rightAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.rightAnchor : superview.rightAnchor, constant: -edgeInsets.right)
    }
    else {
      constraint = view.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -edgeInsets.right)
    }
    constraint.isActive = true
    constraints.append(constraint)

    if #available(iOS 11.0, *) {
      constraint = view.bottomAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor, constant: -edgeInsets.bottom)
    }
    else {
      constraint = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -edgeInsets.bottom)
    }
    constraint.isActive = true
    constraints.append(constraint)

    if #available(iOS 11.0, *) {
      constraint = view.leftAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.leftAnchor : superview.leftAnchor, constant: edgeInsets.left)
    }
    else {
      constraint = view.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: edgeInsets.left)
    }
    constraint.isActive = true
    constraints.append(constraint)

    return constraints
  }

  @discardableResult public func alignGreaterThanOrEqualToSuperview(_ anchorType: AutoLayoutAnchorType = [.top, .right, .bottom, .left], offset: CGFloat = 0.0, useSafeArea: Bool = false) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    guard let superview = view.superview else { return constraints }

    if anchorType.contains(.top) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.topAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor, constant: offset)
      }
      else {
        constraint = view.topAnchor.constraint(greaterThanOrEqualTo: superview.topAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.right) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.rightAnchor.constraint(lessThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.rightAnchor : superview.rightAnchor, constant: -offset)
      }
      else {
        constraint = view.rightAnchor.constraint(lessThanOrEqualTo: superview.rightAnchor, constant: -offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.bottom) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.bottomAnchor.constraint(lessThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor, constant: -offset)
      }
      else {
        constraint = view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor, constant: -offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.left) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.leftAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.leftAnchor : superview.leftAnchor, constant: offset)
      }
      else {
        constraint = view.leftAnchor.constraint(greaterThanOrEqualTo: superview.leftAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.centerX) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.centerXAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.centerXAnchor : superview.centerXAnchor, constant: offset)
      }
      else {
        constraint = view.centerXAnchor.constraint(greaterThanOrEqualTo: superview.centerXAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.centerY) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.centerYAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.centerYAnchor : superview.centerYAnchor, constant: offset)
      }
      else {
        constraint = view.centerYAnchor.constraint(greaterThanOrEqualTo: superview.centerYAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.width) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.widthAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.widthAnchor : superview.widthAnchor, constant: offset)
      }
      else {
        constraint = view.widthAnchor.constraint(greaterThanOrEqualTo: superview.widthAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.height) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.heightAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.heightAnchor : superview.heightAnchor, constant: offset)
      }
      else {
        constraint = view.heightAnchor.constraint(greaterThanOrEqualTo: superview.heightAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    return constraints
  }

  @discardableResult public func alignLessThanOrEqualToSuperview(_ anchorType: AutoLayoutAnchorType = [.top, .right, .bottom, .left], offset: CGFloat = 0.0, useSafeArea: Bool = false) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    guard let superview = view.superview else { return constraints }

    if anchorType.contains(.top) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.topAnchor.constraint(lessThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor, constant: offset)
      }
      else {
        constraint = view.topAnchor.constraint(lessThanOrEqualTo: superview.topAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.right) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.rightAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.rightAnchor : superview.rightAnchor, constant: -offset)
      }
      else {
        constraint = view.rightAnchor.constraint(greaterThanOrEqualTo: superview.rightAnchor, constant: -offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.bottom) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor, constant: -offset)
      }
      else {
        constraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: superview.bottomAnchor, constant: -offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.left) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.leftAnchor.constraint(lessThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.leftAnchor : superview.leftAnchor, constant: offset)
      }
      else {
        constraint = view.leftAnchor.constraint(lessThanOrEqualTo: superview.leftAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.centerX) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.centerXAnchor.constraint(lessThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.centerXAnchor : superview.centerXAnchor, constant: offset)
      }
      else {
        constraint = view.centerXAnchor.constraint(lessThanOrEqualTo: superview.centerXAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.centerY) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.centerYAnchor.constraint(lessThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.centerYAnchor : superview.centerYAnchor, constant: offset)
      }
      else {
        constraint = view.centerYAnchor.constraint(lessThanOrEqualTo: superview.centerYAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.width) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.widthAnchor.constraint(lessThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.widthAnchor : superview.widthAnchor, constant: offset)
      }
      else {
        constraint = view.widthAnchor.constraint(lessThanOrEqualTo: superview.widthAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.height) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.heightAnchor.constraint(lessThanOrEqualTo: useSafeArea ? superview.safeAreaLayoutGuide.heightAnchor : superview.heightAnchor, constant: offset)
      }
      else {
        constraint = view.heightAnchor.constraint(lessThanOrEqualTo: superview.heightAnchor, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    return constraints
  }

  @discardableResult public func align(_ anchorType: AutoLayoutAnchorType, to toView: UIView, for toAnchorType: AutoLayoutAnchorType? = nil, offset: CGFloat = 0.0, useSafeArea: Bool = false) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    let t = toAnchorType ?? anchorType

    if anchorType.contains(.top) {
      if t.contains(.top) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.topAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.topAnchor : toView.topAnchor, constant: offset)
        }
        else {
          constraint = view.topAnchor.constraint(equalTo: toView.topAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.bottom) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.topAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.bottomAnchor : toView.bottomAnchor, constant: offset)
        }
        else {
          constraint = view.topAnchor.constraint(equalTo: toView.bottomAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerY) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.topAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.centerYAnchor : toView.centerYAnchor, constant: offset)
        }
        else {
          constraint = view.topAnchor.constraint(equalTo: toView.centerYAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.right) {
      if t.contains(.right) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.rightAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.rightAnchor : toView.rightAnchor, constant: offset)
        }
        else {
          constraint = view.rightAnchor.constraint(equalTo: toView.rightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.left) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.rightAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.leftAnchor : toView.leftAnchor, constant: offset)
        }
        else {
          constraint = view.rightAnchor.constraint(equalTo: toView.leftAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerX) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.rightAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.centerXAnchor : toView.centerXAnchor, constant: offset)
        }
        else {
          constraint = view.rightAnchor.constraint(equalTo: toView.centerXAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.bottom) {
      if t.contains(.bottom) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.bottomAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.bottomAnchor : toView.bottomAnchor, constant: offset)
        }
        else {
          constraint = view.bottomAnchor.constraint(equalTo: toView.bottomAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.top) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.bottomAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.topAnchor : toView.topAnchor, constant: offset)
        }
        else {
          constraint = view.bottomAnchor.constraint(equalTo: toView.topAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerY) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.bottomAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.centerYAnchor : toView.centerYAnchor, constant: offset)
        }
        else {
          constraint = view.bottomAnchor.constraint(equalTo: toView.centerYAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.left) {
      if t.contains(.left) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.leftAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.leftAnchor : toView.leftAnchor, constant: offset)
        }
        else {
          constraint = view.leftAnchor.constraint(equalTo: toView.leftAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.right) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.leftAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.rightAnchor : toView.rightAnchor, constant: offset)
        }
        else {
          constraint = view.leftAnchor.constraint(equalTo: toView.rightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerX) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.leftAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.centerXAnchor : toView.centerXAnchor, constant: offset)
        }
        else {
          constraint = view.leftAnchor.constraint(equalTo: toView.centerXAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.centerX) {
      if t.contains(.left) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerXAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.leftAnchor : toView.leftAnchor, constant: offset)
        }
        else {
          constraint = view.centerXAnchor.constraint(equalTo: toView.leftAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.right) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerXAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.rightAnchor : toView.rightAnchor, constant: offset)
        }
        else {
          constraint = view.centerXAnchor.constraint(equalTo: toView.rightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerX) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerXAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.centerXAnchor : toView.centerXAnchor, constant: offset)
        }
        else {
          constraint = view.centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.centerY) {
      if t.contains(.bottom) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerYAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.bottomAnchor : toView.bottomAnchor, constant: offset)
        }
        else {
          constraint = view.centerYAnchor.constraint(equalTo: toView.bottomAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.top) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerYAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.topAnchor : toView.topAnchor, constant: offset)
        }
        else {
          constraint = view.centerYAnchor.constraint(equalTo: toView.topAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerY) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerYAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.centerYAnchor : toView.centerYAnchor, constant: offset)
        }
        else {
          constraint = view.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.width) {
      if t.contains(.width) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.widthAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.widthAnchor : toView.widthAnchor, constant: offset)
        }
        else {
          constraint = view.widthAnchor.constraint(equalTo: toView.widthAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.height) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.widthAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.heightAnchor : toView.heightAnchor, constant: offset)
        }
        else {
          constraint = view.widthAnchor.constraint(equalTo: toView.heightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.height) {
      if t.contains(.width) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.heightAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.widthAnchor : toView.widthAnchor, constant: offset)
        }
        else {
          constraint = view.heightAnchor.constraint(equalTo: toView.widthAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.height) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.heightAnchor.constraint(equalTo: useSafeArea ? toView.safeAreaLayoutGuide.heightAnchor : toView.heightAnchor, constant: offset)
        }
        else {
          constraint = view.heightAnchor.constraint(equalTo: toView.heightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    return constraints
  }

  @discardableResult public func alignGreaterOrEqual(_ anchorType: AutoLayoutAnchorType, to toView: UIView, for toAnchorType: AutoLayoutAnchorType? = nil, offset: CGFloat = 0.0, useSafeArea: Bool = false) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    let t = toAnchorType ?? anchorType

    if anchorType.contains(.top) {
      if t.contains(.top) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.topAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.topAnchor : toView.topAnchor, constant: offset)
        }
        else {
          constraint = view.topAnchor.constraint(greaterThanOrEqualTo: toView.topAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.bottom) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.topAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.bottomAnchor : toView.bottomAnchor, constant: offset)
        }
        else {
          constraint = view.topAnchor.constraint(greaterThanOrEqualTo: toView.bottomAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerY) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.topAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerYAnchor : toView.centerYAnchor, constant: offset)
        }
        else {
          constraint = view.topAnchor.constraint(greaterThanOrEqualTo: toView.centerYAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.right) {
      if t.contains(.right) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.rightAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.rightAnchor : toView.rightAnchor, constant: offset)
        }
        else {
          constraint = view.rightAnchor.constraint(greaterThanOrEqualTo: toView.rightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.left) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.rightAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.leftAnchor : toView.leftAnchor, constant: offset)
        }
        else {
          constraint = view.rightAnchor.constraint(greaterThanOrEqualTo: toView.leftAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerX) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.rightAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerXAnchor : toView.centerXAnchor, constant: offset)
        }
        else {
          constraint = view.rightAnchor.constraint(greaterThanOrEqualTo: toView.centerXAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.bottom) {
      if t.contains(.bottom) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.bottomAnchor : toView.bottomAnchor, constant: offset)
        }
        else {
          constraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: toView.bottomAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.top) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.topAnchor : toView.topAnchor, constant: offset)
        }
        else {
          constraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: toView.topAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerY) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerYAnchor : toView.centerYAnchor, constant: offset)
        }
        else {
          constraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: toView.centerYAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.left) {
      if t.contains(.left) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.leftAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.leftAnchor : toView.leftAnchor, constant: offset)
        }
        else {
          constraint = view.leftAnchor.constraint(greaterThanOrEqualTo: toView.leftAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.right) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.leftAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.rightAnchor : toView.rightAnchor, constant: offset)
        }
        else {
          constraint = view.leftAnchor.constraint(greaterThanOrEqualTo: toView.rightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerX) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.leftAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerXAnchor : toView.centerXAnchor, constant: offset)
        }
        else {
          constraint = view.leftAnchor.constraint(greaterThanOrEqualTo: toView.centerXAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.centerX) {
      if t.contains(.left) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerXAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.leftAnchor : toView.leftAnchor, constant: offset)
        }
        else {
          constraint = view.centerXAnchor.constraint(greaterThanOrEqualTo: toView.leftAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.right) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerXAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.rightAnchor : toView.rightAnchor, constant: offset)
        }
        else {
          constraint = view.centerXAnchor.constraint(greaterThanOrEqualTo: toView.rightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerX) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerXAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerXAnchor : toView.centerXAnchor, constant: offset)
        }
        else {
          constraint = view.centerXAnchor.constraint(greaterThanOrEqualTo: toView.centerXAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.centerY) {
      if t.contains(.bottom) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerYAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.bottomAnchor : toView.bottomAnchor, constant: offset)
        }
        else {
          constraint = view.centerYAnchor.constraint(greaterThanOrEqualTo: toView.bottomAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.top) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerYAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.topAnchor : toView.topAnchor, constant: offset)
        }
        else {
          constraint = view.centerYAnchor.constraint(greaterThanOrEqualTo: toView.topAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerY) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerYAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerYAnchor : toView.centerYAnchor, constant: offset)
        }
        else {
          constraint = view.centerYAnchor.constraint(greaterThanOrEqualTo: toView.centerYAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.width) {
      if t.contains(.width) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.widthAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.widthAnchor : toView.widthAnchor, constant: offset)
        }
        else {
          constraint = view.widthAnchor.constraint(greaterThanOrEqualTo: toView.widthAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.height) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.widthAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.heightAnchor : toView.heightAnchor, constant: offset)
        }
        else {
          constraint = view.widthAnchor.constraint(greaterThanOrEqualTo: toView.heightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.height) {
      if t.contains(.width) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.heightAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.widthAnchor : toView.widthAnchor, constant: offset)
        }
        else {
          constraint = view.heightAnchor.constraint(greaterThanOrEqualTo: toView.widthAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.height) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.heightAnchor.constraint(greaterThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.heightAnchor : toView.heightAnchor, constant: offset)
        }
        else {
          constraint = view.heightAnchor.constraint(greaterThanOrEqualTo: toView.heightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    return constraints
  }

  @discardableResult public func alignLessOrEqual(_ anchorType: AutoLayoutAnchorType, to toView: UIView, for toAnchorType: AutoLayoutAnchorType? = nil, offset: CGFloat = 0.0, useSafeArea: Bool = false) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    let t = toAnchorType ?? anchorType

    if anchorType.contains(.top) {
      if t.contains(.top) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.topAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.topAnchor : toView.topAnchor, constant: offset)
        }
        else {
          constraint = view.topAnchor.constraint(lessThanOrEqualTo: toView.topAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.bottom) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.topAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.bottomAnchor : toView.bottomAnchor, constant: offset)
        }
        else {
          constraint = view.topAnchor.constraint(lessThanOrEqualTo: toView.bottomAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerY) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.topAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerYAnchor : toView.centerYAnchor, constant: offset)
        }
        else {
          constraint = view.topAnchor.constraint(lessThanOrEqualTo: toView.centerYAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.right) {
      if t.contains(.right) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.rightAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.rightAnchor : toView.rightAnchor, constant: offset)
        }
        else {
          constraint = view.rightAnchor.constraint(lessThanOrEqualTo: toView.rightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.left) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.rightAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.leftAnchor : toView.leftAnchor, constant: offset)
        }
        else {
          constraint = view.rightAnchor.constraint(lessThanOrEqualTo: toView.leftAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerX) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.rightAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerXAnchor : toView.centerXAnchor, constant: offset)
        }
        else {
          constraint = view.rightAnchor.constraint(lessThanOrEqualTo: toView.centerXAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.bottom) {
      if t.contains(.bottom) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.bottomAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.bottomAnchor : toView.bottomAnchor, constant: offset)
        }
        else {
          constraint = view.bottomAnchor.constraint(lessThanOrEqualTo: toView.bottomAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.top) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.bottomAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.topAnchor : toView.topAnchor, constant: offset)
        }
        else {
          constraint = view.bottomAnchor.constraint(lessThanOrEqualTo: toView.topAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerY) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.bottomAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerYAnchor : toView.centerYAnchor, constant: offset)
        }
        else {
          constraint = view.bottomAnchor.constraint(lessThanOrEqualTo: toView.centerYAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.left) {
      if t.contains(.left) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.leftAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.leftAnchor : toView.leftAnchor, constant: offset)
        }
        else {
          constraint = view.leftAnchor.constraint(lessThanOrEqualTo: toView.leftAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.right) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.leftAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.rightAnchor : toView.rightAnchor, constant: offset)
        }
        else {
          constraint = view.leftAnchor.constraint(lessThanOrEqualTo: toView.rightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerX) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.leftAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerXAnchor : toView.centerXAnchor, constant: offset)
        }
        else {
          constraint = view.leftAnchor.constraint(lessThanOrEqualTo: toView.centerXAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.centerX) {
      if t.contains(.left) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerXAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.leftAnchor : toView.leftAnchor, constant: offset)
        }
        else {
          constraint = view.centerXAnchor.constraint(lessThanOrEqualTo: toView.leftAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.right) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerXAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.rightAnchor : toView.rightAnchor, constant: offset)
        }
        else {
          constraint = view.centerXAnchor.constraint(lessThanOrEqualTo: toView.rightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerX) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerXAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerXAnchor : toView.centerXAnchor, constant: offset)
        }
        else {
          constraint = view.centerXAnchor.constraint(lessThanOrEqualTo: toView.centerXAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.centerY) {
      if t.contains(.bottom) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerYAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.bottomAnchor : toView.bottomAnchor, constant: offset)
        }
        else {
          constraint = view.centerYAnchor.constraint(lessThanOrEqualTo: toView.bottomAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.top) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerYAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.topAnchor : toView.topAnchor, constant: offset)
        }
        else {
          constraint = view.centerYAnchor.constraint(lessThanOrEqualTo: toView.topAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.centerY) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.centerYAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.centerYAnchor : toView.centerYAnchor, constant: offset)
        }
        else {
          constraint = view.centerYAnchor.constraint(lessThanOrEqualTo: toView.centerYAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.width) {
      if t.contains(.width) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.widthAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.widthAnchor : toView.widthAnchor, constant: offset)
        }
        else {
          constraint = view.widthAnchor.constraint(lessThanOrEqualTo: toView.widthAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.height) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.widthAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.heightAnchor : toView.heightAnchor, constant: offset)
        }
        else {
          constraint = view.widthAnchor.constraint(lessThanOrEqualTo: toView.heightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    if anchorType.contains(.height) {
      if t.contains(.width) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.heightAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.widthAnchor : toView.widthAnchor, constant: offset)
        }
        else {
          constraint = view.heightAnchor.constraint(lessThanOrEqualTo: toView.widthAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }

      if t.contains(.height) {
        var constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
          constraint = view.heightAnchor.constraint(lessThanOrEqualTo: useSafeArea ? toView.safeAreaLayoutGuide.heightAnchor : toView.heightAnchor, constant: offset)
        }
        else {
          constraint = view.heightAnchor.constraint(lessThanOrEqualTo: toView.heightAnchor, constant: offset)
        }
        constraint.isActive = true
        constraints.append(constraint)
      }
    }

    return constraints
  }

  @discardableResult public func fitDimensionToSuperview(_ anchorType: AutoLayoutAnchorType = [.width, .height], multiplier: CGFloat = 1.0, offset: CGFloat = 0.0, useSafeArea: Bool = false) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    guard let superview = view.superview else { return constraints }

    if anchorType.contains(.width) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.widthAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.widthAnchor : superview.widthAnchor, multiplier: multiplier, constant: offset)
      }
      else {
        constraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: multiplier, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    if anchorType.contains(.height) {
      var constraint: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        constraint = view.heightAnchor.constraint(equalTo: useSafeArea ? superview.safeAreaLayoutGuide.heightAnchor : superview.heightAnchor, multiplier: multiplier, constant: offset)
      }
      else {
        constraint = view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: multiplier, constant: offset)
      }
      constraint.isActive = true
      constraints.append(constraint)
    }

    return constraints
  }

  @discardableResult public func width(_ value: CGFloat) -> NSLayoutConstraint {
    let constraint = view.widthAnchor.constraint(equalToConstant: value)
    constraint.isActive = true
    return constraint
  }

  @discardableResult public func height(_ value: CGFloat) -> NSLayoutConstraint {
    let constraint = view.heightAnchor.constraint(equalToConstant: value)
    constraint.isActive = true
    return constraint
  }

  @discardableResult public func aspectRatio(_ value: CGFloat) -> NSLayoutConstraint {
    let constraint = view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: value)
    constraint.isActive = true
    return constraint
  }

  @discardableResult public func horizontalSpacing(to toView: UIView, spacing: CGFloat = 0.0, useSafeArea: Bool = false) -> NSLayoutConstraint {
    var constraint: NSLayoutConstraint
    if #available(iOS 11.0, *) {
      constraint = toView.leftAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.rightAnchor : view.rightAnchor, constant: spacing)
    }
    else {
      constraint = toView.leftAnchor.constraint(equalTo: view.rightAnchor, constant: spacing)
    }
    constraint.isActive = true
    return constraint
  }

  @discardableResult public func verticalSpacing(to toView: UIView, spacing: CGFloat = 0.0, useSafeArea: Bool = false) -> NSLayoutConstraint {
    var constraint: NSLayoutConstraint
    if #available(iOS 11.0, *) {
      constraint = toView.topAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor, constant: spacing)
    }
    else {
      constraint = toView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: spacing)
    }
    constraint.isActive = true
    return constraint
  }
}
