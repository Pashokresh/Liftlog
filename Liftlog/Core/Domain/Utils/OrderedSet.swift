//
//  OrderedSet.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 21.04.26.
//

/// A hybrid data structure that combines the insertion-order preservation of `Array`
/// with the constant-time lookup performance of `Set`.
///
/// `OrderedSet` maintains elements in the order they were first inserted while ensuring
/// uniqueness. This provides O(1) membership testing and ordered iteration, making it
/// ideal for scenarios requiring both fast lookups and deterministic ordering.
///
/// ## Usage Example
///
/// ```swift
/// var tags = OrderedSet<String>()
/// tags.insert("swift")
/// tags.insert("ios")
/// tags.insert("swift") // Duplicate - won't be added
///
/// print(tags.elements) // ["swift", "ios"]
/// print(tags.containts("swift")) // true
/// ```
///
/// ## Performance Characteristics
///
/// - **Insert**: O(1) average case for hash operations, O(1) for array append
/// - **Remove**: O(n) due to array linear search and removal
/// - **Contains**: O(1) average case via hash lookup
/// - **Access by index**: O(1) for subscript operations
/// - **Space complexity**: O(n) - stores elements in both array and set
///
/// ## Thread Safety
///
/// `OrderedSet` is not thread-safe. External synchronization is required for
/// concurrent access from multiple threads.
///
/// ## Conformances
///
/// - `Collection`: Provides iteration, subscripting, and standard collection algorithms
/// - Preserves insertion order through conformance to `Collection`
///
/// - Note: Consider using `OrderedSet` from Swift Collections package for production
///   use cases requiring more advanced features like efficient removal by index.
///
/// - Important: The internal implementation maintains two data structures which
///   doubles memory usage. Ensure this tradeoff is acceptable for your use case.
struct OrderedSet<T: Hashable> {
    // MARK: - Private Storage
    
    /// Maintains insertion order of elements.
    /// - Complexity: O(n) space where n is the number of unique elements.
    private var array: [T] = .init()
    
    /// Provides fast O(1) membership testing.
    /// - Complexity: O(n) space where n is the number of unique elements.
    private var set: Set<T> = .init()
    
    // MARK: - Public Properties
    
    /// Returns all elements in insertion order.
    ///
    /// The returned array reflects the order in which elements were first inserted.
    /// Subsequent insertions of duplicate elements do not affect ordering.
    ///
    /// - Complexity: O(1)
    var elements: [T] {
        array
    }
    
    /// The number of unique elements in the ordered set.
    ///
    /// This value is maintained efficiently and always matches the count of both
    /// internal storage structures.
    ///
    /// - Complexity: O(1)
    var count: Int {
        array.count
    }
    
    /// Returns `true` if the ordered set contains no elements.
    ///
    /// - Complexity: O(1)
    var isEmpty: Bool {
        array.isEmpty
    }
    
    // MARK: - Mutating Methods
    
    /// Inserts the given element into the ordered set if it is not already present.
    ///
    /// If the element is already present, this method has no effect. The element
    /// retains its original position in the insertion order.
    ///
    /// ```swift
    /// var numbers = OrderedSet<Int>()
    /// numbers.insert(1) // Adds 1 at position 0
    /// numbers.insert(2) // Adds 2 at position 1
    /// numbers.insert(1) // No effect - already present
    /// print(numbers.elements) // [1, 2]
    /// ```
    ///
    /// - Parameter item: The element to insert.
    /// - Complexity: O(1) average case for hash operations and array append.
    mutating func insert(_ item: T) {
        if !set.contains(item) {
            array.append(item)
            set.insert(item)
        }
    }
    
    /// Removes the specified element from the ordered set if it exists.
    ///
    /// If the element is not present, this method has no effect. Removal preserves
    /// the relative order of remaining elements.
    ///
    /// ```swift
    /// var numbers = OrderedSet<Int>()
    /// numbers.insert(1)
    /// numbers.insert(2)
    /// numbers.insert(3)
    /// numbers.remove(2)
    /// print(numbers.elements) // [1, 3]
    /// ```
    ///
    /// - Parameter item: The element to remove.
    /// - Complexity: O(n) where n is the number of elements, due to array linear
    ///   search and removal.
    /// - Warning: Consider avoiding frequent removals on large datasets. For better
    ///   removal performance, consider maintaining element-to-index mapping.
    mutating func remove(_ item: T) {
        if set.contains(item) {
            array.removeAll { item == $0 }
            set.remove(item)
        }
    }
    
    /// Removes all elements from the ordered set.
    ///
    /// This method invalidates all indices and leaves the ordered set empty.
    ///
    /// - Parameter keepingCapacity: If `true`, the ordered set's allocated storage
    ///   is preserved. If `false`, storage is released. Default is `false`.
    /// - Complexity: O(n) where n is the number of elements.
    mutating func removeAll(keepingCapacity: Bool = false) {
        array.removeAll(keepingCapacity: keepingCapacity)
        set.removeAll(keepingCapacity: keepingCapacity)
    }
    
    // MARK: - Query Methods
    
    /// Returns a Boolean value indicating whether the ordered set contains the given element.
    ///
    /// This method leverages the underlying set for O(1) average-case lookup performance.
    ///
    /// ```swift
    /// let languages = OrderedSet<String>()
    /// languages.insert("Swift")
    /// print(languages.containts("Swift")) // true
    /// print(languages.containts("Python")) // false
    /// ```
    ///
    /// - Parameter item: The element to search for.
    /// - Returns: `true` if the element exists in the ordered set; otherwise, `false`.
    /// - Complexity: O(1) average case for hash-based lookup.
    /// - Note: There is a typo in the method name. Consider renaming to `contains(_:)`.
    func containts(_ item: T) -> Bool {
        set.contains(item)
    }
}

// MARK: - Collection Conformance

/// Collection conformance provides standard iteration and subscript access.
///
/// By conforming to `Collection`, `OrderedSet` gains access to a rich set of
/// algorithms including `map`, `filter`, `reduce`, and more. Iteration occurs
/// in insertion order.
///
/// ```swift
/// let numbers = OrderedSet<Int>()
/// numbers.insert(3)
/// numbers.insert(1)
/// numbers.insert(2)
///
/// for number in numbers {
///     print(number) // Prints: 3, 1, 2 (insertion order)
/// }
///
/// let doubled = numbers.map { $0 * 2 } // [6, 2, 4]
/// ```
extension OrderedSet: Collection {
    /// The position of the first element in a nonempty ordered set.
    ///
    /// If the ordered set is empty, `startIndex` equals `endIndex`.
    ///
    /// - Complexity: O(1)
    var startIndex: Int {
        array.startIndex
    }
    
    /// The position one greater than the last valid subscript argument.
    ///
    /// `endIndex` is not a valid subscript argument and should not be used to access elements.
    ///
    /// - Complexity: O(1)
    var endIndex: Int {
        array.endIndex
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the ordered set. `i` must be less than `endIndex`.
    /// - Returns: The index value immediately after `i`.
    /// - Complexity: O(1)
    func index(after i: Int) -> Int {
        array.index(after: i)
    }
    
    /// Accesses the element at the specified position.
    ///
    /// Elements are indexed in insertion order, starting from 0.
    ///
    /// ```swift
    /// let languages = OrderedSet<String>()
    /// languages.insert("Swift")
    /// languages.insert("Objective-C")
    /// print(languages[0]) // "Swift"
    /// print(languages[1]) // "Objective-C"
    /// ```
    ///
    /// - Parameter position: The position of the element to access. `position` must
    ///   be a valid index that is less than `endIndex`.
    /// - Returns: The element at the specified index.
    /// - Complexity: O(1)
    /// - Precondition: `position` must be a valid index of the ordered set.
    subscript(position: Int) -> T {
        array[position]
    }
}
