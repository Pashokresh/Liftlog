//
//  Request.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import CoreData
import Foundation

func fetchRequest<T: NSManagedObject>(for: T.Type, with ids: [UUID]) throws
    -> NSFetchRequest<T> {
        guard let request = T.fetchRequest() as? NSFetchRequest<T> else {
            throw LiftlogError.failure(description: "Failed to create fetch request")
        }
        request.predicate = NSPredicate(format: "id IN %@", ids)
        return request
}
