//
//  OnboardingView.swift
//  Routory
//
//  Created by 서동환 on 7/1/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class OnboardingView: UIView {
    
    // MARK: - UI Components
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let closeButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .xMark.withTintColor(.white, renderingMode: .alwaysOriginal)
        config.contentInsets = .zero
        
        $0.configuration = config
    }
    
    // MARK: - Getter
    
    var getCloseButton: UIButton { closeButton }
    
    // MARK: - Initializer
    
    init(mode: OnboardingMode) {
        super.init(frame: .zero)
        configure(mode: mode)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

private extension OnboardingView {
    func configure(mode: OnboardingMode) {
        setHierarchy()
        setStyles(mode: mode)
        setConstraints()
    }
    
    func setHierarchy() {
        self.addSubviews(imageView, closeButton)
    }
    
    func setStyles(mode: OnboardingMode) {
        switch mode {
        case .home:
            break
        case .calendar:
            imageView.image = .onboardingCalendar
        }
    }
    
    func setConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(47)
            $0.leading.equalToSuperview().inset(3)
        }
    }
}
