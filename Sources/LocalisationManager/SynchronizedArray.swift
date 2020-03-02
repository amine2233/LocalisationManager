import Foundation

/// A thread-safe array.
public class SynchronizedArray<Element> {
    fileprivate let queue: DispatchQueue
    fileprivate var array: [Element]

    public init(label: String = "com.intechconsulting.synchronized_array") {
        self.queue = DispatchQueue(label: label, attributes: .concurrent)
        self.array = []
    }
}

// MARK: - Properties
public extension SynchronizedArray {

    /// The first element of the collection.
    public var first: Element? {
        var result: Element?
        queue.sync { result = self.array.first }
        return result
    }

    /// The last element of the collection.
    public var last: Element? {
        var result: Element?
        queue.sync { result = self.array.last }
        return result
    }

    /// The number of elements in the array.
    public var count: Int {
        var result = 0
        queue.sync { result = self.array.count }
        return result
    }

    /// A Boolean value indicating whether the collection is empty.
    public var isEmpty: Bool {
        var result = false
        queue.sync { result = self.array.isEmpty }
        return result
    }

    /// A textual representation of the array and its elements.
    public var description: String {
        var result = ""
        queue.sync { result = self.array.description }
        return result
    }
}

// MARK: - Immutable
public extension SynchronizedArray {
    /// Returns the first element of the sequence that satisfies the given predicate or nil if no such element is found.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    /// - Returns: The first match or nil if there was no match.
    public func first(where predicate: (Element) -> Bool) -> Element? {
        var result: Element?
        queue.sync { result = self.array.first(where: predicate) }
        return result
    }

    /// Returns an array containing, in order, the elements of the sequence that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned array.
    /// - Returns: An array of the elements that includeElement allowed.
    public func filter(_ isIncluded: (Element) -> Bool) -> [Element] {
        var result = [Element]()
        queue.sync { result = self.array.filter(isIncluded) }
        return result
    }

    /// Returns the first index in which an element of the collection satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: The index of the first element for which predicate returns true. If no elements in the collection satisfy the given predicate, returns nil.
    public func index(where predicate: (Element) -> Bool) -> Int? {
        var result: Int?
        queue.sync { result = self.array.index(where: predicate) }
        return result
    }

    /// Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
    /// - Returns: A sorted array of the collection’s elements.
    public func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        var result = [Element]()
        queue.sync { result = self.array.sorted(by: areInIncreasingOrder) }
        return result
    }

    /// Returns an array containing the non-nil results of calling the given transformation with each element of this sequence.
    ///
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-nil results of calling transform with each element of the sequence.
    public func compactMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        queue.sync { result = self.array.compactMap(transform) }
        return result
    }

    /// Calls the given closure on each element in the sequence in the same order as a for-in loop.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a parameter.
    public func forEach(_ body: (Element) -> Void) {
        queue.sync { self.array.forEach(body) }
    }

    /// Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: true if the sequence contains an element that satisfies predicate; otherwise, false.
    public func contains(where predicate: (Element) -> Bool) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(where: predicate) }
        return result
    }
}

// MARK: - Mutable
public extension SynchronizedArray {

    /// Adds a new element at the end of the array.
    ///
    /// - Parameter element: The element to append to the array.
    public func append( _ element: Element) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }

    /// Adds a new element at the end of the array.
    ///
    /// - Parameter element: The element to append to the array.
    public func append( _ elements: [Element]) {
        queue.async(flags: .barrier) {
            self.array += elements
        }
    }

    /// Inserts a new element at the specified position.
    ///
    /// - Parameters:
    ///   - element: The new element to insert into the array.
    ///   - index: The position at which to insert the new element.
    public func insert( _ element: Element, at index: Int) {
        queue.async(flags: .barrier) {
            self.array.insert(element, at: index)
        }
    }

    /// Removes and returns the element at the specified position.
    ///
    /// - Parameters:
    ///   - index: The position of the element to remove.
    ///   - completion: The handler with the removed element.
    public func remove(at index: Int, completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let element = self.array.remove(at: index)

            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }

    /// Removes and returns the element at the specified position.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    ///   - completion: The handler with the removed element.
    public func remove(where predicate: @escaping (Element) -> Bool, completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            guard let index = self.array.index(where: predicate) else { return }
            let element = self.array.remove(at: index)

            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }

    /// Removes all elements from the array.
    ///
    /// - Parameter completion: The handler with the removed elements.
    public func removeAll(completion: (([Element]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let elements = self.array
            self.array.removeAll()

            DispatchQueue.main.async {
                completion?(elements)
            }
        }
    }
}

public extension SynchronizedArray {

    /// Accesses the element at the specified position if it exists.
    ///
    /// - Parameter index: The position of the element to access.
    /// - Returns: optional element if it exists.
    public subscript(index: Int) -> Element? {
        get {
            var result: Element?

            queue.sync {
                guard self.array.startIndex..<self.array.endIndex ~= index else { return }
                result = self.array[index]
            }

            return result
        }
        set {
            guard let newValue = newValue else { return }

            queue.async(flags: .barrier) {
                self.array[index] = newValue
            }
        }
    }
}


// MARK: - Equatable
public extension SynchronizedArray where Element: Equatable {

    /// Returns a Boolean value indicating whether the sequence contains the given element.
    ///
    /// - Parameter element: The element to find in the sequence.
    /// - Returns: true if the element was found in the sequence; otherwise, false.
    public func contains(_ element: Element) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(element) }
        return result
    }

    /// Removes and the specified element.
    ///
    /// - Parameter element: An element to search for in the collection.
    public func remove(_ element: Element, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            defer { DispatchQueue.main.async { completion?() } }
            guard let index = self.array.index(of: element) else { return }
            self.array.remove(at: index)
        }
    }

    public static func -=(left: inout SynchronizedArray, right: Element) {
        left.remove(right)
    }
}

// MARK: - Infix operators
public extension SynchronizedArray {

    public static func +=(left: inout SynchronizedArray, right: Element) {
        left.append(right)
    }

    public static func +=(left: inout SynchronizedArray, right: [Element]) {
        left.append(right)
    }
}