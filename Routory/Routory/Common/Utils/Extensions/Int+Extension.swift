//
//  Int+Extension.swift
//  Routory
//
//  Created by 송규섭 on 6/12/25.
//

import Foundation

extension Int {
    var withComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
