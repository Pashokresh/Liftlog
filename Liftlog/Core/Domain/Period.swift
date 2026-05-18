//
//  Period.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Foundation

enum Period: String, CaseIterable, Identifiable {
    case threeMonths = "3M"
    case sixMonths = "6M"
    case year = "1Y"
    case all = "All"

    var id: String { self.rawValue }

    var startDate: Date {
        let calendar = Calendar.current
        switch self {
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: .now) ?? .now
        case .sixMonths:
            return calendar.date(byAdding: .month, value: -6, to: .now) ?? .now
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: .now) ?? .now
        case .all:
            return .distantPast
        }
    }

    var localizedName: String {
        switch self {
        case .threeMonths: AppLocalization.threeMonths
        case .sixMonths: AppLocalization.sixMonths
        case .year: AppLocalization.oneYear
        case .all: AppLocalization.allTime
        }
    }
}
