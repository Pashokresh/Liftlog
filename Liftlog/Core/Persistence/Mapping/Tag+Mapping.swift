//
//  Tag+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

extension Tag {
    func toDomain() -> TagModel {
        TagModel(
            id: id ?? UUID(),
            name: name ?? ""
        )
    }
}
