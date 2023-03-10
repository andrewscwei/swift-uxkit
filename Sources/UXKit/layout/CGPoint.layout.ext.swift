// © GHOZT

import Foundation

extension CGPoint {
  /// Returns the point at the center of a list of points.
  ///
  /// - Parameters:
  ///   - points: A list of points to determine the center point.
  ///
  /// - Returns: The center point.
  public static func midPoint(_ points: CGPoint...) -> CGPoint? {
    return midPoint(points)
  }

  /// Returns the point at the center of a list of points.
  ///
  /// - Parameters:
  ///   - points: A list of points to determine the center point.
  ///
  /// - Returns: The center point.
  public static func midPoint(_ points: [CGPoint]) -> CGPoint? {
    var xMin: CGFloat?
    var yMin: CGFloat?
    var xMax: CGFloat?
    var yMax: CGFloat?

    for point in points {
      if xMin == nil || point.x < xMin! { xMin = point.x }
      if yMin == nil || point.y < yMin! { yMin = point.y }
      if xMax == nil || point.x > xMax! { xMax = point.x }
      if yMax == nil || point.y > yMax! { yMax = point.y }
    }

    guard xMin != nil, yMin != nil, xMax != nil, yMax != nil else { return nil }

    return CGPoint(x: (xMax! - xMin!)*0.5 + xMin!, y: (yMax! - yMin!)*0.5 + yMin!)
  }

  /// The point with location (0.25,0.25).
  public static let quarter = CGPoint(x: 0.25, y: 0.25)

  /// The point with location (0.5,0.5).
  public static let half = CGPoint(x: 0.5, y: 0.5)

  /// The point with location (1,1).
  public static let one = CGPoint(x: 1.0, y: 1.0)
}
