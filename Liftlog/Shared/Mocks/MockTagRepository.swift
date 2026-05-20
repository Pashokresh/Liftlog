//
//  MockTagRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.02.26.
//

import Foundation

final class MockTagRepository: TagRepositoryProtocol {
    private var tags = TagModel.mocks

    func fetchAll() throws -> [TagModel] {
        tags
    }

    func create(name: String) throws -> TagModel {
        let tag = TagModel(id: UUID(), name: name)
        tags.append(tag)

        return tag
    }

    func update(model: TagModel) throws {
        guard let index = tags.firstIndex(
            where: { $0.id == model.id }
        ) else {
            return
        }
        tags[index] = model
    }

    func delete(_ id: UUID) throws {
        tags.removeAll { $0.id == id }
    }
}
