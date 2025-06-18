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
        addSubviews(appleLoginButton,
                    googleLoginButton)
    }

    func setConstraints() {
        appleLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(googleLoginButton.snp.top).offset(-24)
            $0.height.equalTo(44)
        }
        
        googleLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(96)
        }
    }

    func setStyles() {
        backgroundColor = .white
    }
}
