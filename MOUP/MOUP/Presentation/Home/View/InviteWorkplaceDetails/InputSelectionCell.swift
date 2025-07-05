//
//  InputSelectionCell.swift
//  MOUP
//
//  Created by shinyoungkim on 7/5/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class InputSelectionCell: UIView {
    
    // MARK: - Properties
    
    private let title: String
    let tapRelay = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let radioImageView = UIImageView().then {
        $0.image = UIImage.radioUnselected
    }
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        titleLabel.text = title
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(_ isSelected: Bool) {
        titleLabel.font = isSelected
            ? .headBold(16)
            : .bodyMedium(16)
        
        titleLabel.textColor = isSelected
            ? UIColor.primary600
            : UIColor.gray900
        
        radioImageView.image = isSelected
            ? UIImage.radioSelected
            : UIImage.radioUnselected
        
        backgroundColor = isSelected
            ? UIColor.primary50
            : .white
        
        layer.borderColor = isSelected
            ? UIColor.primary500.cgColor
            : UIColor.gray400.cgColor
        
        layer.borderWidth = isSelected
            ? 2
            : 1
    }
}

private extension InputSelectionCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setTapGesture()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            titleLabel,
            radioImageView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        radioImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
    
    func setTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(cellDidTap)
        )
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }
    
    @objc func cellDidTap() {
        tapRelay.accept(title)
    }
}
