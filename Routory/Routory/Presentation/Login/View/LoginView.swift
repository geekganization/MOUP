//
//  LoginView.swift
//  Routory
//
//  Created by 양원식 on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class LoginView: UIView {
    
    // MARK: - Properties
    
    var getGoogleLoginButton: UIButton { googleLoginButton }
    var getAppleLoginButton: UIButton { appleLoginButton }

    // MARK: - UI Components
    
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage.logo
    }
    
    private let appTitleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage.appTitle
    }
    
    private let sloganLabel = UILabel().then {
        $0.text = "근무 시간, 일정, 급여까지\n알바의 모든 것을 한 곳에서 관리해요!"
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray700
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let appleLoginButton = UIButton().then {
        $0.setImage(.appleSignIn, for: .normal)
    }

    private let googleLoginButton = UIButton().then {
        $0.setImage(.googleSignIn, for: .normal)
    }
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - UI Setup

private extension LoginView {
    func configure() {
        setHierarchy()
        setConstraints()
        setStyles()
    }

    func setHierarchy() {
        addSubviews(
            logoImageView,
            appTitleImageView,
            sloganLabel,
            appleLoginButton,
            googleLoginButton
        )
    }

    func setConstraints() {
        logoImageView.snp.makeConstraints {
            $0.centerY.equalTo(self.safeAreaLayoutGuide).offset(-100)
            $0.centerX.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(200)
        }
        
        appTitleImageView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom)
            $0.centerX.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(39)
        }
        
        sloganLabel.snp.makeConstraints {
            $0.top.equalTo(appTitleImageView.snp.bottom).offset(16)
            $0.centerX.equalTo(self.safeAreaLayoutGuide)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(googleLoginButton.snp.top).offset(-12)
            $0.height.equalTo(44)
        }
        
        googleLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(86)
            $0.height.equalTo(44)
        }
    }

    func setStyles() {
        backgroundColor = .white
    }
}
