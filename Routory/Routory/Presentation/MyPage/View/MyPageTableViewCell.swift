//
//  MyPageTableViewCell.swift
//  Routory
//
//  Created by shinyoungkim on 6/10/25.
//

import UIKit
import Then
import SnapKit

final class MyPageTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let id = "MyPageTableViewCell"
    
    // MARK: - UI Components
    
    let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = UIColor.gray900
    }
    
    private let rightArrow = UIImageView().then {
        $0.image = UIImage.chevronRight
        $0.contentMode = .scaleAspectFit
    }
    
    private let seperatorView = UIView().then {
        $0.backgroundColor = UIColor.gray400
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyPageTableViewCell {
    
    // MARK: - configure
    private func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    private func setHierarchy() {
        addSubviews(
            titleLabel,
            rightArrow,
            seperatorView
        )
    }
    
    // MARK: - setStyles
    private func setStyles() {
        selectionStyle = .none
    }
    
    // MARK: - setConstraints
    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        rightArrow.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
        
        seperatorView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
