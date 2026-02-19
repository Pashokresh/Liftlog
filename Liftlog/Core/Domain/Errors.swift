//
//  Errors.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

enum LiftlogError: Error {
    case noData(description: String)
    case failure(description: String)
}
