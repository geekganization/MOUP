//
//  ColorBorderView.swift
//  Routory
//
//  Created by 서동환 on 6/16/25.
//

import UIKit

final class ColorBorderView: UIView {
    
    // MARK: - Properties
    
    private let borderColor: UIColor
    
    // MARK: - Initializer
    
    init(frame: CGRect, borderColor: UIColor) {
        self.borderColor = borderColor
        
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let borderPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: rect.width, height: rect.height), cornerRadius: 12)
        let contentPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 0, width: rect.width - 2, height: rect.height), cornerRadius: 10.5)
        borderColor.setFill()
        borderPath.fill()
        
        UIColor.gray100.setFill()
        contentPath.fill()
    }
}

private extension ColorBorderView {
    func configure() {
        setStyles()
    }
    
    func setStyles() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
    }
}
