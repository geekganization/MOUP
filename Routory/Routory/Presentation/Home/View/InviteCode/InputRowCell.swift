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
    
    private var isChecked: Bool = false {
        didSet {
            checkBox.image = isChecked ? .checkboxSelected : .checkboxUnselected
        }
    }
    
    var onCheckToggled: ((Bool) -> Void)?
    
    // MARK: - UI Components

    private let titleLabel = UILabel().then {
        $0.text = "이름"
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let infoIconImageView = UIImageView().then {
        $0.image = UIImage.infoIcon
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
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
    
    private let checkBox = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.image = .checkboxUnselected
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
        isPayday: Bool = false,
        showsCheckbox: Bool = false,
        checked: Bool = false
    ) {
        titleLabel.text = title
        contentLabel.text = content
        rightArrow.isHidden = !showsArrow
        
        let shouldShowIcon = (title == "4대 보험" || title == "야간수당")
        infoIconImageView.isHidden = !shouldShowIcon

        contentContainer.isHidden = true
        contentLabel.removeFromSuperview()
        contentContainer.removeFromSuperview()
        
        if isPayday {
            if contentLabel.superview != contentContainer {
                contentLabel.removeFromSuperview()
                contentContainer.addSubview(contentLabel)
            }

            if contentContainer.superview != contentView {
                contentView.addSubview(contentContainer)
            }

            contentContainer.isHidden = false

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
            if contentLabel.superview != contentView {
                contentLabel.removeFromSuperview()
                contentView.addSubview(contentLabel)
            }

            updateTrailingConstraint(showsArrow: showsArrow)
        }

        checkBox.isHidden = !showsCheckbox
        isChecked = checked
    }
    
    private func updateTrailingConstraint(showsArrow: Bool) {
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
    
    func setIsLastCell(_ isLast: Bool) {
        separatorView.isHidden = isLast
    }
}

private extension InputRowCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
        setGestures()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        contentView.addSubviews(
            titleLabel,
            infoIconImageView,
            contentLabel,
            contentContainer,
            rightArrow,
            checkBox,
            separatorView
        )
        contentContainer.addSubview(contentLabel)
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        infoIconImageView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.size.equalTo(15)
        }
        
        rightArrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        checkBox.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(18)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        separatorView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func setGestures() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapCheckBox)
        )
        checkBox.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapCheckBox() {
        isChecked.toggle()
        onCheckToggled?(isChecked)
    }
}
