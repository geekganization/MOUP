//
//  UILabel+Extension.swift
//  Routory
//
//  Created by 서동환 on 6/6/25.
//

import UIKit

extension UILabel {
    enum LineSpacing {
        case headBold
        case bodyMedium
        case fieldsRegular
        
        var ratio: Double {
            switch self {
            case .headBold:
                return 1.3
            case .bodyMedium:
                return 1.5
            case .fieldsRegular:
                return 1.5
            }
        }
    }
    
    func setLineSpacing(_ lineSpacing: LineSpacing) {
        let style = NSMutableParagraphStyle()
        let lineheight = self.font.pointSize * lineSpacing.ratio  // font size * ratio(Double)
        style.minimumLineHeight = lineheight
        style.maximumLineHeight = lineheight
        
        self.attributedText = NSAttributedString(
            string: self.text ?? "", attributes: [
                .paragraphStyle: style
            ])
    }
}
