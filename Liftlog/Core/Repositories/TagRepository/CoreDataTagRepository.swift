//
//  CoreDataTagRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import Foundation

final class CoreDataTagRepository: TagRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [TagModel] {
        try await context.perform {
            let request = Tag.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "name", ascending: true)
            ]

            return try self.context.fetch(request).map { $0.toDomain() }
        }
    }

    func create(name: String) async throws -> TagModel {
        try await context.perform {
            let tag = Tag(context: self.context)

            tag.id = UUID()
            tag.name = name

            try self.context.save()

            return tag.toDomain()
        }
    }

    func update(model: TagModel) async throws {
        try await context.perform {
            let tag = try self.fetchTag(model.id)

            tag.name = model.name

            try self.context.save()
        }
    }

    func delete(_ id: UUID) async throws {
        try await context.perform {
            let tag = try self.fetchTag(id)

            self.context.delete(tag)
            try self.context.save()
        }
    }
}

extension CoreDataTagRepository {

    fileprivate func fetchTag(_ id: UUID) throws -> Tag {
        let request = fetchRequest(for: Tag.self, with: [id])

        guard let tag = try context.fetch(request).first else {
            throw LiftlogError.noData(
                description: String(localized: "Tag was not found")
            )
        }

        return tag
    }
}
