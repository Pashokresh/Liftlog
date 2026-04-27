//
//  OrderedSetTests.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 27.04.26.
//

import Testing
@testable import Liftlog

@Suite("OrderedSet Tests")
struct OrderedSetTests {
    
    // MARK: - Initialization Tests
    
    @Test("Empty OrderedSet initialization")
    func emptyInitialization() {
        let set = OrderedSet<Int>()
        
        #expect(set.count == 0)
        #expect(set.elements.isEmpty)
    }
    
    // MARK: - Insert Tests
    
    @Test("Insert single element")
    func insertSingleElement() {
        var set = OrderedSet<String>()
        set.insert("Bench Press")
        
        #expect(set.count == 1)
        #expect(set.contains("Bench Press"))
        #expect(set.elements == ["Bench Press"])
    }
    
    @Test("Insert multiple unique elements")
    func insertMultipleElements() {
        var set = OrderedSet<String>()
        set.insert("Squat")
        set.insert("Deadlift")
        set.insert("Bench Press")
        
        #expect(set.count == 3)
        #expect(set.elements == ["Squat", "Deadlift", "Bench Press"])
    }
    
    @Test("Insert duplicate element preserves order")
    func insertDuplicateElement() {
        var set = OrderedSet<Int>()
        set.insert(1)
        set.insert(2)
        set.insert(3)
        set.insert(2) // Duplicate
        
        #expect(set.count == 3)
        #expect(set.elements == [1, 2, 3])
    }
    
    @Test("Insert maintains insertion order")
    func insertionOrderPreserved() {
        var set = OrderedSet<Int>()
        let numbers = [5, 3, 8, 1, 9]
        
        for number in numbers {
            set.insert(number)
        }
        
        #expect(set.elements == numbers)
    }
    
    // MARK: - Remove Tests
    
    @Test("Remove existing element")
    func removeExistingElement() {
        var set = OrderedSet<String>()
        set.insert("Push")
        set.insert("Pull")
        set.insert("Legs")
        
        set.remove("Pull")
        
        #expect(set.count == 2)
        #expect(set.elements == ["Push", "Legs"])
        #expect(!set.contains("Pull"))
    }
    
    @Test("Remove non-existing element does nothing")
    func removeNonExistingElement() {
        var set = OrderedSet<Int>()
        set.insert(1)
        set.insert(2)
        
        set.remove(999)
        
        #expect(set.count == 2)
        #expect(set.elements == [1, 2])
    }
    
    @Test("Remove from empty set does nothing")
    func removeFromEmptySet() {
        var set = OrderedSet<String>()
        set.remove("Anything")
        
        #expect(set.count == 0)
        #expect(set.elements.isEmpty)
    }
    
    @Test("Remove maintains order of remaining elements")
    func removePreservesOrder() {
        var set = OrderedSet<Int>()
        set.insert(1)
        set.insert(2)
        set.insert(3)
        set.insert(4)
        set.insert(5)
        
        set.remove(3)
        
        #expect(set.elements == [1, 2, 4, 5])
    }
    
    // MARK: - Contains Tests
    
    @Test("Contains returns true for existing element")
    func containsExistingElement() {
        var set = OrderedSet<String>()
        set.insert("Biceps")
        set.insert("Triceps")
        
        #expect(set.contains("Biceps"))
        #expect(set.contains("Triceps"))
    }
    
    @Test("Contains returns false for non-existing element")
    func containsNonExistingElement() {
        var set = OrderedSet<String>()
        set.insert("Chest")
        
        #expect(!set.contains("Back"))
    }
    
    @Test("Contains on empty set returns false")
    func containsOnEmptySet() {
        let set = OrderedSet<Int>()
        
        #expect(!set.contains(42))
    }
    
    // MARK: - Collection Conformance Tests
    
    @Test("Iteration order matches insertion order")
    func iterationOrder() {
        var set = OrderedSet<Int>()
        let numbers = [3, 1, 4, 1, 5, 9, 2, 6]
        
        for number in numbers {
            set.insert(number)
        }
        
        var iteratedElements: [Int] = []
        for element in set {
            iteratedElements.append(element)
        }
        
        #expect(iteratedElements == [3, 1, 4, 5, 9, 2, 6])
    }
    
    @Test("Subscript access")
    func subscriptAccess() {
        var set = OrderedSet<String>()
        set.insert("First")
        set.insert("Second")
        set.insert("Third")
        
        #expect(set[0] == "First")
        #expect(set[1] == "Second")
        #expect(set[2] == "Third")
    }
    
    @Test("Start and end indices")
    func startEndIndices() {
        var set = OrderedSet<Int>()
        set.insert(10)
        set.insert(20)
        set.insert(30)
        
        #expect(set.startIndex == 0)
        #expect(set.endIndex == 3)
    }
    
    @Test("Empty set indices")
    func emptySetIndices() {
        let set = OrderedSet<String>()
        
        #expect(set.startIndex == set.endIndex)
    }
    
    @Test("Map operation works correctly")
    func mapOperation() {
        var set = OrderedSet<Int>()
        set.insert(1)
        set.insert(2)
        set.insert(3)
        
        let doubled = set.map { $0 * 2 }
        
        #expect(doubled == [2, 4, 6])
    }
    
    @Test("Filter operation works correctly")
    func filterOperation() {
        var set = OrderedSet<Int>()
        set.insert(1)
        set.insert(2)
        set.insert(3)
        set.insert(4)
        set.insert(5)
        
        let evens = set.filter { $0 % 2 == 0 }
        
        #expect(evens == [2, 4])
    }
    
    @Test("First and last elements")
    func firstLastElements() {
        var set = OrderedSet<String>()
        set.insert("Alpha")
        set.insert("Beta")
        set.insert("Gamma")
        
        #expect(set.first == "Alpha")
        #expect(set.last == "Gamma")
    }
    
    @Test("First on empty set returns nil")
    func firstOnEmptySet() {
        let set = OrderedSet<Int>()
        
        #expect(set.first == nil)
    }
    
    // MARK: - Complex Scenarios
    
    @Test("Multiple insert and remove operations")
    func complexOperations() {
        var set = OrderedSet<String>()
        
        set.insert("Monday")
        set.insert("Tuesday")
        set.insert("Wednesday")
        #expect(set.count == 3)
        
        set.remove("Tuesday")
        #expect(set.count == 2)
        #expect(set.elements == ["Monday", "Wednesday"])
        
        set.insert("Thursday")
        set.insert("Friday")
        #expect(set.count == 4)
        
        set.insert("Monday") // Duplicate
        #expect(set.count == 4)
        
        #expect(set.elements == ["Monday", "Wednesday", "Thursday", "Friday"])
    }
    
    @Test("Insert after removing same element")
    func insertAfterRemove() {
        var set = OrderedSet<Int>()
        set.insert(1)
        set.insert(2)
        set.insert(3)
        
        set.remove(2)
        #expect(set.elements == [1, 3])
        
        set.insert(2) // Insert again
        #expect(set.elements == [1, 3, 2]) // Added at the end
    }
    
    @Test("Working with custom hashable types")
    func customHashableType() {
        struct Exercise: Hashable {
            let name: String
            let sets: Int
        }
        
        var set = OrderedSet<Exercise>()
        let squat = Exercise(name: "Squat", sets: 5)
        let bench = Exercise(name: "Bench Press", sets: 3)
        
        set.insert(squat)
        set.insert(bench)
        set.insert(squat) // Duplicate
        
        #expect(set.count == 2)
        #expect(set.contains(squat))
        #expect(set.contains(bench))
    }
    
    // MARK: - Edge Cases
    
    @Test("Large number of elements")
    func largeNumberOfElements() {
        var set = OrderedSet<Int>()
        let range = 0..<1000
        
        for number in range {
            set.insert(number)
        }
        
        #expect(set.count == 1000)
        #expect(set.elements == Array(range))
    }
    
    @Test("Remove all elements")
    func removeAllElements() {
        var set = OrderedSet<String>()
        set.insert("A")
        set.insert("B")
        set.insert("C")
        
        set.remove("A")
        set.remove("B")
        set.remove("C")
        
        #expect(set.count == 0)
        #expect(set.elements.isEmpty)
    }
}
