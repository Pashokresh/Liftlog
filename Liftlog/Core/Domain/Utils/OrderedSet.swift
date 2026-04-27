//
//  OrderedSet.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 21.04.26.
//

/// A collection that keeps elements unique and remembers the order they were added.
///
/// This is basically an array that won't let you add duplicates. Elements stay in the order
/// you inserted them, but each one can only appear once.
///
/// ```swift
/// var exercises = OrderedSet<String>()
/// exercises.insert("Squat")
/// exercises.insert("Bench Press")
/// exercises.insert("Squat") // Does nothing - already in there
///
/// print(exercises.elements) // ["Squat", "Bench Press"]
/// ```
struct OrderedSet<T: Hashable> {
    private var array: [T] = []
    private var set: Set<T> = []
    
    /// All the elements in the order they were added.
    var elements: [T] {
        array
    }
    
    /// How many elements are in the collection.
    var count: Int {
        array.count
    }
    
    /// The first element, or `nil` if empty.
    var first: T? {
        array.first
    }
    
    /// The last element, or `nil` if empty.
    var last: T? {
        array.last
    }
    
    /// Adds an element to the collection.
    ///
    /// If the element is already in there, nothing happens.
    /// New elements are always added to the end.
    mutating func insert(_ value: T) {
        guard !set.contains(value) else { return }
        array.append(value)
        set.insert(value)
    }
    
    /// Removes an element from the collection.
    ///
    /// If the element isn't in there, nothing happens.
    mutating func remove(_ value: T) {
        guard set.contains(value) else { return }
        set.remove(value)
        array.removeAll { $0 == value }
    }
    
    /// Checks if an element is in the collection.
    func contains(_ value: T) -> Bool {
        set.contains(value)
    }
}

// MARK: - Collection

extension OrderedSet: Collection {
    
    var startIndex: Int {
        array.startIndex
    }
    
    var endIndex: Int {
        array.endIndex
    }
    
    subscript(position: Int) -> T {
        array[position]
    }
    
    func index(after i: Int) -> Int {
        array.index(after: i)
    }
}
