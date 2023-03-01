// © GHOZT

import Foundation

extension DataCollectionViewController {

  /// Gets the first cell index of a datum at a given section.
  ///
  /// - Parameters:
  ///   - datum: The datum.
  ///   - section: The section.
  ///   - filtered: Specifies if referring to unfiltered or filtered data.
  ///
  /// - Returns: The first index (if found).
  public func firstIndex(for datum: T, at section: Int, filtered: Bool? = nil) -> Int? {
    guard section < numberOfSections else { return nil }
    return data(for: section, filtered: filtered)?.firstIndex { areDataEqual(a: $0, b: datum) }
  }

  /// Gets the cell indexes of a datum at a given section. Note that the same
  /// datum can repeat within the same section.
  ///
  /// - Parameters:
  ///   - datum: The datum.
  ///   - section: The section.
  ///   - filtered: Specifies if referring to unfiltered or filtered data.
  ///
  /// - Returns: The indexes (if found).
  public func indexes(for datum: T, at section: Int, filtered: Bool? = nil) -> [Int] {
    guard
      section < numberOfSections,
      let data = data(for: section, filtered: filtered)
    else { return [] }

    var out = [Int]()

    for (i, v) in data.enumerated() {
      if areDataEqual(a: datum, b: v) {
        out.append(i)
      }
    }

    return out
  }

  /// Gets the first index path of a datum.
  ///
  /// - Parameters:
  ///   - datum: The datum.
  ///   - filtered: Specifies if referring to unfiltered data or filtered data.
  ///
  /// - Returns: The first index path if found.
  public func firstIndexPath(for datum: T, filtered: Bool? = nil) -> IndexPath? {
    for section in 0 ..< numberOfSections {
      if let index = self.firstIndex(for: datum, at: section, filtered: filtered) {
        return IndexPath(item: index, section: section)
      }
    }

    return nil
  }

  /// Gets all the index paths of a datum.
  ///
  /// - Parameters:
  ///   - datum: The datum.
  ///   - filtered: Specifies if referring to unfiltered data or filtered data.
  ///
  /// - Returns: The index paths if found.
  public func indexPaths(for datum: T, filtered: Bool? = nil) -> [IndexPath] {
    var out = [IndexPath]()

    for section in 0 ..< numberOfSections {
      let indexes = self.indexes(for: datum, at: section, filtered: filtered)
      out += indexes.map { IndexPath(item: $0, section: section) }
    }

    return out
  }
}
