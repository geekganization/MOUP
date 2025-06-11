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
    
    private let titleLabel = UILabel().then {
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
    
    // MARK: - Getter
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
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

private extension MyPageTableViewCell {    
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            titleLabel,
            rightArrow,
            seperatorView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        selectionStyle = .none
    }
    
    // MARK: - setConstraints
    func setConstraints() {
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
