//
//  RepositoryError.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

enum RepositoryError: Error {
    case notFound(entity: String)
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case invalidData(description: String)
}
