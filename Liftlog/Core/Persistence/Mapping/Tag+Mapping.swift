//
//  Tag+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

extension Tag {
    func toDomain() throws -> TagModel {
        guard let id = id else {
            throw RepositoryError.invalidData(
                description: AppLocalization.missingRecordID
            )
        }

        return TagModel(
            id: id,
            name: name ?? ""
        )
    }
}
