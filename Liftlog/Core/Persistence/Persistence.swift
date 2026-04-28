//
//  Persistence.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Liftlog")
        if inMemory {
            guard let storeDescription = container.persistentStoreDescriptions.first else {
                preconditionFailure("No store description found")
            }
            storeDescription.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores {_, error in
            if let error = error as NSError? {
                assertionFailure("Failed to load persistent store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
