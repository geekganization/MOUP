//
//  ColorPickerRowView.swift
//  MOUP
//
//  Created by shinyoungkim on 7/5/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class ColorPickerRowView: UIView {
    
    // MARK: - Properties
    
    let tapRelay = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let colorView = UIView().then {
        $0.backgroundColor = .systemRed
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "빨간색"
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = UIImage.chevronRight.withRenderingMode(.alwaysTemplate)
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .gray700
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

private extension ColorPickerRowView {
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
            colorView,
            titleLabel,
            arrowImageView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        colorView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(12)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(colorView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(12)
        }
    }
    
    func setTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(rowDidTap)
        )
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }
    
    @objc func rowDidTap() {
        tapRelay.accept(())
    }
}
