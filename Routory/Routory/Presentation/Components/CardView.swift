//
//  CardView.swift
//  Routory
//
//  Created by 송규섭 on 6/10/25.
//

import UIKit

class CardView: UIView {
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

private extension CardView {
    // MARK: - configure
    func configure() {
        setStyles()
    }
    // MARK: - setStyles
    func setStyles() {
        layer.shadowColor = UIColor.gray900.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5
        layer.masksToBounds = false

        layer.cornerRadius = 12

        backgroundColor = .systemBackground
    }
}

