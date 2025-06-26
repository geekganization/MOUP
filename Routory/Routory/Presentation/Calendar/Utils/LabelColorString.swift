//
//  LabelColorString.swift
//  Routory
//
//  Created by 서동환 on 6/25/25.
//

import UIKit

enum LabelColorString: String, CaseIterable {
    case _default = "기본색"
    case red = "빨간색"
    case orange = "주황색"
    case yellow = "노란색"
    case green = "초록색"
    case blue = "파란색"
    case purple = "보라색"
    case indigo = "남색"
    
    var labelColor: UIColor {
        switch self {
        case ._default:
            return .primary500
        case .red:
            return .systemRed
        case .orange:
            return .systemOrange
        case .yellow:
            return .systemYellow
        case .green:
            return .systemGreen
        case .blue:
            return .systemBlue
        case .purple:
            return .systemPurple
        case .indigo:
            return .systemIndigo
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case ._default:
            return .primary100
        case .red:
            return .redBackground
        case .orange:
            return .orangeBackground
        case .yellow:
            return .yellowBackground
        case .green:
            return .greenBackground
        case .blue:
            return .blueBackground
        case .purple:
            return .purpleBackground
        case .indigo:
            return .indigoBackground
        }
    }
    
    var textColor: UIColor {
        switch self {
        case ._default:
            return .primary600
        case .red:
            return .redText
        case .orange:
            return .orangeText
        case .yellow:
            return .yellowText
        case .green:
            return .greenText
        case .blue:
            return .blueText
        case .purple:
            return .purpleText
        case .indigo:
            return .indigoText
        }
    }
}
