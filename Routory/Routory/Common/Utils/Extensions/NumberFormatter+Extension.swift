//
//  NumberFormatter+Extension.swift
//  Routory
//
//  Created by 서동환 on 6/24/25.
//

import Foundation

import Then

extension NumberFormatter {
    static let decimalFormatter = NumberFormatter().then {
        $0.numberStyle = .decimal
        $0.locale = Locale(identifier: "ko_KR")
    }
}
