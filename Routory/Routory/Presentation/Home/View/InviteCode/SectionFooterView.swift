//
//  SectionFooterView.swift
//  Routory
//
//  Created by shinyoungkim on 6/29/25.
//

import UIKit
import Then
import SnapKit

final class SectionFooterView: UICollectionReusableView {
    
    // MARK: - Properties
    
    static let identifier = "SectionFooterView"
    
    // MARK: - UI Components
    
    private let noticeLabel = UILabel().then {
        $0.text = "* 오후 10시 이후 야간수당을 받는 경우 체크해주세요"
        $0.font = .bodyMedium(12)
        $0.textColor = .gray700
    }
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SectionFooterView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubview(noticeLabel)
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        noticeLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
}
