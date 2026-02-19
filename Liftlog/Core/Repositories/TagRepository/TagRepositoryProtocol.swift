//
//  TagRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

protocol TagRepositoryProtocol {
    
    func fetchAll() throws -> [TagModel]
    
    func create(name: String) throws -> TagModel
    
    func update(model: TagModel) throws
    
    func delete(_ id: UUID) throws
}

protocol TagEntityProviderProtocol {
    
    func fetchTag(_ id: UUID) throws -> Tag
    
    func fetchTags(_ ids: [UUID]) throws -> [Tag]
}
