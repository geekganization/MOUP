//
//  DeleteAccountFailModalViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/23/25.
//

import UIKit
import Then
import SnapKit
import RxSwift

final class DeleteAccountFailModalViewController: UIViewController {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let modal = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "탈퇴에 실패했어요."
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }
    
    private let messageLabel = UILabel().then {
        $0.text = "일시적인 오류가 발생했습니다. 다시 시도해주세요."
        $0.font = .bodyMedium(14)
        $0.textColor = .gray700
        $0.setLineSpacing(.bodyMedium)
        $0.numberOfLines = 0
    }
    
    private let confirmButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "확인"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .primary500
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .buttonSemibold(18)
            return outgoing
        }

        $0.configuration = config
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    func update(errorMessage: String) {
        messageLabel.text = errorMessage
    }
}

private extension DeleteAccountFailModalViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        modal.addSubviews(
            titleLabel,
            messageLabel,
            confirmButton
        )
        
        view.addSubview(modal)
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .modalBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        modal.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(188)
            $0.centerY.equalTo(view.safeAreaLayoutGuide)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalTo(titleLabel.snp.leading)
        }
        
        confirmButton.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        confirmButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
