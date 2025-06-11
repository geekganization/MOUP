//
//  CardButton.swift
//  Routory
//
//  Created by 양원식 on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class CardButton: UIButton {

    // MARK: - UI Components

    private let iconImageView = UIImageView()
    private let cardTitleLabel = UILabel()
    private let vStack = UIStackView()

    // MARK: - Init

    init(image: UIImage?, title: String) {
        super.init(frame: .zero)
        iconImageView.image = image
        cardTitleLabel.text = title
        configure()
    }

    @available(*, unavailable, message: "Use init(image:title:) instead")
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Selected Style

    override var isSelected: Bool {
        didSet { updateStyle() }
    }

    private func updateStyle() {
        if isSelected {
            layer.borderColor = UIColor.primary500.cgColor
            layer.borderWidth = 2
            layer.shadowColor = UIColor(red: 250/255, green: 109/255, blue: 70/255, alpha: 0.7).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowRadius = 4
            cardTitleLabel.textColor = .primary500
            cardTitleLabel.font = .headBold(16)
        } else {
            layer.borderColor = UIColor.gray400.cgColor
            layer.shadowOpacity = 0
            cardTitleLabel.textColor = .gray900
            cardTitleLabel.font = .bodyMedium(16)
        }
    }
}

// MARK: - UI Setup

private extension CardButton {
    func configure() {
        setHierarchy()
        setConstraints()
        setStyles()
        updateStyle()
    }

    func setHierarchy() {
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 21
        vStack.isLayoutMarginsRelativeArrangement = true
        vStack.layoutMargins = UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14)
        vStack.isUserInteractionEnabled = false

        cardTitleLabel.textAlignment = .center

        vStack.addArrangedSubviews(iconImageView, cardTitleLabel)
        addSubview(vStack)
    }

    func setConstraints() {
        vStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func setStyles() {
        layer.cornerRadius = 12
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.gray400.cgColor
        backgroundColor = .white
        clipsToBounds = false
        iconImageView.contentMode = .scaleAspectFit
        cardTitleLabel.textColor = .gray900
        cardTitleLabel.font = .bodyMedium(16)
    }
}
