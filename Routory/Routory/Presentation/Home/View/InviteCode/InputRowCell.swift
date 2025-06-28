//
//  InputRowCell.swift
//  Routory
//
//  Created by shinyoungkim on 6/28/25.
//

import UIKit
import Then
import SnapKit

final class InputRowCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "InputRowCell"
    
    // MARK: - UI Components

    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods

    func configure(with title: String) {
        titleLabel.text = title
    }
    
    func setIsLastCell(_ isLast: Bool) {
        separatorView.isHidden = isLast
    }
}

private extension InputRowCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstratins()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        contentView.addSubviews(
            titleLabel,
            separatorView
        )
    }
    
    // MARK: - setConstraints
    func setConstratins() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        separatorView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
