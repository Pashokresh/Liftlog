//
//  Utils.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import Foundation

func formattedDuration(_ duration: Double) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: duration) ?? "0s"
}
