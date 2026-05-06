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

            return try self.context.fetchOrThrow(request).map { $0.toDomain() }
        }
    }

    func create(name: String) async throws -> TagModel {
        try await context.perform {
            let tag = Tag(context: self.context)

            tag.id = UUID()
            tag.name = name

            try self.context.saveOrThrow()

            return tag.toDomain()
        }
    }

    func update(model: TagModel) async throws {
        try await context.perform {
            let tag = try self.fetchTag(model.id)

            tag.name = model.name

            try self.context.saveOrThrow()
        }
    }

    func delete(_ id: UUID) async throws {
        try await context.perform {
            let tag = try self.fetchTag(id)

            self.context.delete(tag)
            try self.context.saveOrThrow()
        }
    }
}

extension CoreDataTagRepository {
    func fetchTag(_ id: UUID) throws -> Tag {
        let request = try fetchRequest(for: Tag.self, with: [id])

        guard let tag = try context.fetch(request).first else {
            throw RepositoryError.notFound(entity: "Tag")
        }

        return tag
    }
}
