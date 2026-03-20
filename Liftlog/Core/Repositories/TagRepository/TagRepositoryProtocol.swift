//
//  TagRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import Foundation

protocol TagRepositoryProtocol {

    func fetchAll() async throws -> [TagModel]

    func create(name: String) async throws -> TagModel

    func update(model: TagModel) async throws

    func delete(_ id: UUID) async throws
}
