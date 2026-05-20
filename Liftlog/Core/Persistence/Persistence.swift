//
//  Persistence.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Liftlog")
        if inMemory {
            guard let storeDescription = container.persistentStoreDescriptions.first else {
                preconditionFailure("No store description found")
            }
            storeDescription.url = URL(fileURLWithPath: "/dev/null")
        } else {
            guard let storeDescription = container.persistentStoreDescriptions.first else {
                preconditionFailure("No store description found")
            }
            storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.pavel.martynenkov.Liftlog"
            )
            storeDescription.setOption(
                true as NSNumber,
                forKey: NSMigratePersistentStoresAutomaticallyOption
            )
            storeDescription.setOption(
                true as NSNumber,
                forKey: NSInferMappingModelAutomaticallyOption
            )
        }
        container.loadPersistentStores {_, error in
            if let error = error as NSError? {
                assertionFailure("Failed to load persistent store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
