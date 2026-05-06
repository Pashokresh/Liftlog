//
//  NSManagedObjectContext+Extensions.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import CoreData

extension NSManagedObjectContext {
    func saveOrThrow() throws {
        do {
            try save()
        } catch {
            throw RepositoryError.saveFailed(underlying: error)
        }
    }

    func fetchOrThrow<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> [T] {
        do {
            return try fetch(request)
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
}
