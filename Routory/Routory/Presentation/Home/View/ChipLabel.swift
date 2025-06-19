//
//  ChipLabel.swift
//  Routory
//
//  Created by 송규섭 on 6/19/25.
//

import UIKit
import SnapKit
import Then

final class ChipLabel: UIView {
    // MARK: - Properties
    private let title: String
    private let color: UIColor
    private let titleColor: UIColor
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .fieldsRegular(12)
    }
    
    // MARK: - Initializer
    init(title: String, color: UIColor, titleColor: UIColor) {
        self.title = title
        self.color = color
        self.titleColor = titleColor
        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
}

private extension ChipLabel {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(titleLabel)
    }

    // MARK: - setStyles
    func setStyles() {
        self.layer.cornerRadius = 10
        self.backgroundColor = color
        self.titleLabel.textColor = titleColor
        self.titleLabel.text = title
    }

    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(8)
            $0.directionalVerticalEdges.equalToSuperview().inset(2)
        }
    }
}

