//
//  Double+Formatting.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 07.05.26.
//

import Foundation

extension Double {
    var formattedWeight: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = ""
        return "\(formatter.string(from: NSNumber(value: self)) ?? String(self)) kg"
    }
    
    var formattedVolume: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ""
        return "\(formatter.string(from: NSNumber(value: self)) ?? String(self)) kg"
    }
}
