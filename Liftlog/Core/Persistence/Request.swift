//
//  Request.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import CoreData
import Foundation

func fetchRequest<T: NSManagedObject>(for: T.Type, with ids: [UUID])
    -> NSFetchRequest<T>
{
    let request = T.fetchRequest() as! NSFetchRequest<T>
    request.predicate = NSPredicate(format: "id IN %@", ids)
    return request
}
