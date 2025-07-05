//
//  SectionHeaderView.swift
//  MOUP
//
//  Created by shinyoungkim on 7/5/25.
//

import UIKit
import Then
import SnapKit

final class SectionHeaderView: UIView {
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }
    
    // MARK: - Initializer
    
    init(title: String, isRequired: Bool) {
        super.init(frame: .zero)
        
        setTitle(title, isRequired: isRequired)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTitle(_ title: String, isRequired: Bool) {
        if isRequired {
            let fullText = "\(title) *"
            let attributedString = NSMutableAttributedString(string: fullText)
            let range = (fullText as NSString).range(of: "*")
            attributedString.addAttribute(
                .foregroundColor,
                value: UIColor.primary500,
                range: range
            )
            titleLabel.attributedText = attributedString
        } else {
            titleLabel.text = title
        }
    }
}

private extension SectionHeaderView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubview(titleLabel)
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview().inset(12)
        }
    }
}
