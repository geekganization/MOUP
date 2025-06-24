//
//  InviteCodeEmptyModalViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/18/25.
//

import UIKit
import Then
import RxSwift

final class InviteCodeEmptyModalViewController: UIViewController {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let inviteCodeErrorLabel = UILabel().then {
        $0.text = "초대코드를 다시 확인해 주세요."
        $0.font = .headBold(18)
        $0.setLineSpacing(.headBold)
        $0.textColor = .gray900
    }
    
    private let noWorkplaceFoundLabel = UILabel().then {
        $0.text = "입력한 초대코드에 해당하는 근무지가 없어요.\n다시 한 번 확인해 주세요!"
        $0.font = .bodyMedium(14)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray700
        $0.numberOfLines = 0
    }
    
    private let confirmButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "확인"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .primary500
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .buttonSemibold(14)
            return outgoing
        }

        $0.configuration = config
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let modalView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension InviteCodeEmptyModalViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        modalView.addSubviews(
            inviteCodeErrorLabel,
            noWorkplaceFoundLabel,
            confirmButton
        )
        
        view.addSubview(modalView)
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .modalBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        modalView.snp.makeConstraints {
            $0.centerX.centerY.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(231)
        }
        
        inviteCodeErrorLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        
        noWorkplaceFoundLabel.snp.makeConstraints {
            $0.top.equalTo(inviteCodeErrorLabel.snp.bottom).offset(20)
            $0.leading.equalTo(inviteCodeErrorLabel.snp.leading)
        }
        
        confirmButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        confirmButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
