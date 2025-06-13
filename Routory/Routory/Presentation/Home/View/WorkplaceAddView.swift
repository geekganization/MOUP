//
//  WorkplaceAddView.swift
//  Routory
//
//  Created by shinyoungkim on 6/13/25.
//

import UIKit
import Then
import SnapKit

final class WorkplaceAddView: UIView {
    
    // MARK: - UI Components
    
    private let handleView = UIView().then {
        $0.backgroundColor = .gray400
        $0.layer.cornerRadius = 2
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "새 근무지 등록"
        $0.font = .headBold(18)
        $0.setLineSpacing(.headBold)
        $0.textColor = .gray900
    }
    
    private let seperatorView = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    private let titleView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let enterInviteCodeIcon = UIImageView().then {
        $0.image = UIImage.mail
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WorkplaceAddView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        titleView.addSubviews(
            handleView,
            titleLabel,
            seperatorView
        )
        
        addSubviews(titleView)
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        handleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.width.equalTo(45)
            $0.height.equalTo(4)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(handleView.snp.bottom).offset(12)
            $0.leading.equalTo(16)
        }
        
        seperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(64)
        }
    }
}
