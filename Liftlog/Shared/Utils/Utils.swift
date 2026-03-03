//
//  Utils.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import Foundation

func formattedDuration(_ duration: Double) -> String {
    let seconds = DateComponents.init(second: Int(duration))
    
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .short
    
    return formatter.string(from: seconds) ?? "0:00"
}
