//
//  RepositoryError.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

/// Infrastructure-level errors thrown by CoreData repository implementations.
///
/// These are never surfaced directly to the UI. Use cases catch them and re-throw
/// the appropriate `DomainError` so the domain layer stays decoupled from CoreData.
enum RepositoryError: Error {
    /// The requested entity was not found in the persistent store.
    case notFound(entity: String)
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    /// The persisted data is in an unexpected state and cannot be mapped to a domain model.
    case invalidData(description: String)
}
