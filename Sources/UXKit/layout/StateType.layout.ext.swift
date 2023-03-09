// © GHOZT

import BaseKit

/// `StateType` extension for defining common UI state types.
extension StateType {

  /// Use this type when the layout of a view has changed, i.e. changes to its
  /// or its subviews' frame, bounds, constraints, etc.
  public static let layout = StateType.factory()

  /// Use this type when a component is operating in a different mode, state,
  /// configuration, etc, i.e. a dropdown expanding/collapsing its menu.
  public static let mode = StateType.factory()

  /// Use this type when a component has behavioral changes. This is kinda
  /// similar to `mode`, but you can think of `behavior` as suitable for
  /// higher-level, specific changes, whereas `mode` is lower-level and generic.
  /// As in if `behavior` is to Swift, then `mode` is to Assembly.
  public static let behavior = StateType.factory()

  /// Use this type when the content of a view has changed, i.e. texts, image,
  /// etc.
  public static let content = StateType.factory()

  /// Use this type for selection changes in the UI, i.e. selected items in a
  /// `UICollectionView`, etc.
  public static let selection = StateType.factory()

  /// Use this type for position changes in the UI, i.e. scroll position.
  public static let position = StateType.factory()

  /// Use this type when the focus has changed, i.e. text field focus,
  /// collection item focus, etc.
  public static let focus = StateType.factory()

  /// Use this type for style changes, i.e. colors, backgrounds, fonts, etc.
  public static let style = StateType.factory()

  /// Use this type for changes in application-wide
  /// configuration/settings/preferences.
  public static let config = StateType.factory()

  /// Use this type to notify frame advances, i.e. when using `DisplayLink`.
  public static let frame = StateType.factory()
}
