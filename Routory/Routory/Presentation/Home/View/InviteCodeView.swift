//
//  InviteCodeView.swift
//  Routory
//
//  Created by shinyoungkim on 6/16/25.
//

import UIKit
import Then
import SnapKit

final class InviteCodeView: UIView {
    
    // MARK: - Properties
    
    private let navigationBar = MyPageNavigationBar(title: "새 근무지")
    
    private let titleLabel = UILabel().then {
        $0.text = "초대 코드를 입력해주세요"
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }
    
    private let codeTextField = UITextField().then {
        $0.font = .fieldsRegular(16)
        $0.attributedPlaceholder = NSAttributedString(
            string: "초대 코드",
            attributes: [
                .foregroundColor: UIColor.gray400,
                .font: UIFont.fieldsRegular(16)
            ]
        )
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.setLeftPadding(16)
    }
    
    private let searchButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "조회하기"
        config.baseForegroundColor = .gray500
        config.baseBackgroundColor = .gray300
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .buttonSemibold(14)
            return outgoing
        }

        $0.configuration = config
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Getter
    
    var codeTextFieldView: UITextField { codeTextField }
    var searchButtonView: UIButton { searchButton }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension InviteCodeView {
    func configure() {
        setHierarchy()
        setConstraints()
    }
    
    func setHierarchy() {
        addSubviews(
            navigationBar,
            titleLabel,
            codeTextField,
            searchButton
        )
    }
    
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        
        codeTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        
        searchButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
            $0.bottom.equalToSuperview().inset(46)
        }
    }
}
