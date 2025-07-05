//
//  ArrowValueRowView.swift
//  MOUP
//
//  Created by shinyoungkim on 7/5/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class ArrowValueRowView: UIView {
    
    // MARK: - Properties
    
    let tapRelay = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let valueLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray700
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = UIImage.chevronRight.withRenderingMode(.alwaysTemplate)
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .gray400
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    // MARK: - Initializer
    
    init(title: String, value: String, isLast: Bool = false) {
        titleLabel.text = title
        valueLabel.text = value
        separatorView.isHidden = isLast
        
        super.init(frame: .zero)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ArrowValueRowView {
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
            valueLabel,
            arrowImageView,
            separatorView
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
        
        valueLabel.snp.makeConstraints {
            $0.trailing.equalTo(arrowImageView.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(12)
        }
        
        separatorView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
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
