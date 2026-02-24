//
//  CoreDataTagRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation
import CoreData

final class CoreDataTagRepository: TagRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
        
    func fetchAll() throws -> [TagModel] {
        let request = Tag.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return try context.fetch(request).map { $0.toDomain() }
    }
    
    func create(name: String) throws -> TagModel {
        let tag = Tag(context: context)
        
        tag.id = UUID()
        tag.name = name
        
        try context.save()
        
        return tag.toDomain()
    }
    
    func update(model: TagModel) async throws {
        let tag = try await fetchTag(model.id)
        
        tag.name = model.name
        
        try context.save()
    }
    
    func delete(_ id: UUID) async throws {
        let tag = try await fetchTag(id)
        
        context.delete(tag)
        try context.save()
    }
}

extension CoreDataTagRepository {
    
    fileprivate func fetchTag(_ id: UUID) async throws -> Tag {
        let request = fetchRequest(for: Tag.self, with: [id])
        
        guard let tag = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Tag was not found"))
        }
        
        return tag
    }
}
