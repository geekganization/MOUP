//
//  OtherEventLabel.swift
//  Routory
//
//  Created by 서동환 on 6/13/25.
//

import UIKit

final class OtherEventLabel: UILabel {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.font = .bodyMedium(12)
        self.textColor = .gray500
        self.backgroundColor = .gray200
        self.textAlignment = .left
        self.clipsToBounds = true
        self.layer.cornerRadius = 4
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: .init(top: 0, left: 2, bottom: 0, right: 0)))
    }
}
