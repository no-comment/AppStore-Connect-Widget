//
//  SortedArray.swift
//  AC Widget by NO-COMMENT
//
// inspired by https://github.com/ole/SortedArray/blob/master/Sources/SortedArray.swift
//

import Foundation

/// An array that keeps its elements sorted at all times.
public struct SortedArray<Element> where Element: Comparable & Codable {
    /// The backing store
    public private(set) var elements: [Element]

    /// Whether the array should be sorted increasing (`<`) or decreasing (`>`).
//    fileprivate let areInIncreasingOrder: Bool

    /// Initializes an empty sorted array.
    public init() {
        self.elements = []
    }

    /// Initializes the array with a sequence of unsorted elements.
    public init<S: Sequence>(_ unsorted: S) where S.Element == Element {
        self.elements = unsorted.sorted(by: <)
    }

    /// Initializes the array with a sequence of sorted elements. Only for private use
    private init<S: Sequence>(sorted: S) where S.Element == Element {
        self.elements = Array(sorted)
    }
}

public extension SortedArray {
    /// The last element of the collection.
    var last: Element? {
        return self.elements.last
    }

    /// The first element of the collection.
    var first: Element? {
        return self.elements.first
    }

    /// The number of elements in the sorted array.
    var count: Int {
        return self.elements.count
    }

    /// A Boolean value indicating whether the collection is empty.
    var isEmpty: Bool {
        return self.elements.isEmpty
    }

    /// Inserts a new element into the array, preserving the sort order.
    mutating func insert(_ newElement: Element) {
        guard let first = first, let last = last else {
            // elements array is empty
            elements = [newElement]
            return
        }
        if newElement < first {
            elements.insert(newElement, at: 0)
        } else if newElement > last {
            elements.append(newElement)
        } else {
            self = .init(elements + [newElement])
        }
    }

    /// Like `Sequence.filter(_:)`, but returns a `SortedArray` instead of an `Array`.
    /// We can do this efficiently because filtering doesn't change the sort order.
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> SortedArray<Element> {
        let newElements = try elements.filter(isIncluded)
        return SortedArray(sorted: newElements)
    }

    /// Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
    func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try self.elements.contains(where: predicate)
    }
}

extension SortedArray: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(elements.description) (sorted)"
    }

    public var debugDescription: String {
        return "<SortedArray> \(elements.debugDescription)"
    }
}

extension SortedArray: Codable {
    enum CodingKeys: String, CodingKey {
        case elements
        case areInIncreasingOrder
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.areInIncreasingOrder, forKey: .areInIncreasingOrder)
        try container.encode(self.elements, forKey: .elements)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let unsorted = try values.decode([Element].self, forKey: .elements)
//        let increasing = try values.decode(Bool.self, forKey: .areInIncreasingOrder)

        self.init(unsorted)
    }
}
