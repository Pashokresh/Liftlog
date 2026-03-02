//
//  Errors.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

enum LiftlogError: Error {
    case noData(description: String)
    case failure(description: String)
}

extension LiftlogError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noData(description: let description):
            return "No data: \(description)"
        case .failure(description: let description):
            return "Failure: \(description)"
        }
    }
}
