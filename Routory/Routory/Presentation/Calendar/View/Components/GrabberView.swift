//
//  GrabberView.swift
//  Routory
//
//  Created by 서동환 on 6/16/25.
//

import UIKit

final class GrabberView: UIView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

private extension GrabberView {
    func configure() {
        setStyles()
    }
    
    func setStyles() {
        self.backgroundColor = .gray400
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 2
    }
}
