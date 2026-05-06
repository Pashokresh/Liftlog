//
//  NSManagedObjectContext+Save.swift
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
}
