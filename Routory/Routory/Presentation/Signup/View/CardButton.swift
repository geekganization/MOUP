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
        
        iconImageView.do {
            $0.image = image
            $0.contentMode = .scaleAspectFit
        }
        cardTitleLabel.do {
            $0.text = title
            $0.font = .bodyMedium(16)
            $0.textColor = .gray900
            $0.textAlignment = .center
        }
        vStack.do {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 21
            $0.addArrangedSubviews(iconImageView, cardTitleLabel)
        }
        
        addSubview(vStack)
        vStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        vStack.isLayoutMarginsRelativeArrangement = true
        vStack.layoutMargins = UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14)
        vStack.isUserInteractionEnabled = false
        
        layer.cornerRadius = 12
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.gray400.cgColor
        clipsToBounds = false
        backgroundColor = .white
        updateStyle()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - 스타일 업데이트 (선택/비선택)
    override var isSelected: Bool {
        didSet { updateStyle() }
    }
    private func updateStyle() {
        if isSelected {
            layer.borderColor = UIColor.primary500.cgColor
            layer.borderWidth = 2
            layer.shadowColor = UIColor(red: 250/255, green: 109/255, blue: 70/255, alpha: 0.7).cgColor // #FA6D46, 70%
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowRadius = 4
            cardTitleLabel.textColor = .primary500
            cardTitleLabel.font = .headBold(16)
        } else {
            layer.borderColor = UIColor.gray400.cgColor
            layer.shadowOpacity = 0
            cardTitleLabel.textColor = .gray900
        }
    }
}
