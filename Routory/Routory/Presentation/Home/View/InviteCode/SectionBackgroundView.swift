//
//  SectionBackgroundView.swift
//  Routory
//
//  Created by shinyoungkim on 6/28/25.
//

import UIKit

final class SectionBackgroundView: UICollectionReusableView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SectionBackgroundView {
    // MARK: - configure
    func configure() {
        setStyles()
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
        
        layer.borderColor = UIColor.gray400.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
    }
}
