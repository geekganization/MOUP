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

    // MARK: - UI Components

    private let googleLoginButton = UIButton().then {
        $0.setImage(UIImage(named: "ios_light_sq_SU"), for: .normal)
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
        addSubview(googleLoginButton)
    }

    func setConstraints() {
        googleLoginButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    func setStyles() {
        backgroundColor = .white
    }
}
