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
    
    private var contentTrailingConstraint: Constraint?
    
    // MARK: - UI Components

    private let titleLabel = UILabel().then {
        $0.text = "이름"
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let contentLabel = UILabel().then {
        $0.text = "GS25 분당이매역점"
        $0.font = .bodyMedium(16)
        $0.textColor = .gray700
        $0.textAlignment = .right
    }
    
    private let contentContainer = UIView().then {
        $0.isHidden = true
        $0.backgroundColor = .primary100
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let rightArrow = UIImageView().then {
        $0.image = .chevronRightGray400
        $0.isHidden = true
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


    func update(
        with title: String,
        content: String?,
        showsArrow: Bool = false,
        isPayday: Bool = false
    ) {
        titleLabel.text = title
        contentLabel.text = content
        rightArrow.isHidden = !showsArrow

        contentLabel.removeFromSuperview()
        contentContainer.removeFromSuperview()

        if isPayday {
            contentContainer.isHidden = false
            contentView.addSubview(contentContainer)
            contentContainer.addSubview(contentLabel)

            contentContainer.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(-12)
                $0.height.equalTo(24)
            }

            contentLabel.snp.remakeConstraints {
                $0.horizontalEdges.equalToSuperview().inset(12)
                $0.verticalEdges.equalToSuperview()
            }
        } else {
            contentContainer.isHidden = true
            contentView.addSubview(contentLabel)

            updateTrailingConstraint(showsArrow: showsArrow)
        }
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
            contentLabel,
            contentContainer,
            rightArrow,
            separatorView
        )
        contentContainer.addSubview(contentLabel)
    }
    
    // MARK: - setConstraints
    func setConstratins() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        rightArrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func updateTrailingConstraint(showsArrow: Bool) {
        contentTrailingConstraint?.deactivate()
        contentLabel.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            if showsArrow {
                contentTrailingConstraint = $0.trailing.equalTo(rightArrow.snp.leading).offset(-12).constraint
            } else {
                contentTrailingConstraint = $0.trailing.equalToSuperview().inset(16).constraint
            }
        }
    }
}
