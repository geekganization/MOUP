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
    
    // MARK: - UI Components
    
    let kakaoLoginButton = UIButton().then {
        $0.setImage(UIImage(named: "kakao_login_medium_wide"), for: .normal)
    }

    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(kakaoLoginButton)
    }

    private func setupConstraints() {
        kakaoLoginButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
}

