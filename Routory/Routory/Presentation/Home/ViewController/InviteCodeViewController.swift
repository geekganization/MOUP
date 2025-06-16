//
//  InviteCodeViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/16/25.
//

import UIKit

enum InviteCodeViewState {
    case input
    case result
}

final class InviteCodeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var currentState: InviteCodeViewState = .input
    
    // MARK: - UI Components
    
    private let inviteCodeView = InviteCodeView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = inviteCodeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    private func updateState(to newState: InviteCodeViewState) {
        currentState = newState
        inviteCodeView.update(state: newState)
    }
}

private extension InviteCodeViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setActions()
    }
    
    // MARK: - setStyles
    func setStyles() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
    }
    
    // MARK: - setActions
    func setActions() {
        inviteCodeView.navigationBarView.backButtonView.addTarget(
            self,
            action: #selector(backButtonDidTap),
            for: .touchUpInside
        )
        
        inviteCodeView.codeTextFieldView.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        inviteCodeView.workplaceSearchResultView.workplaceSelectView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(workplaceSelectViewDidTap)
            )
        )
        
        inviteCodeView.searchButtonView.addTarget(
            self,
            action: #selector(searchButtonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let isEmpty = textField.text?.isEmpty ?? true
        updateSearchButtonStyle(enabled: !isEmpty)
    }
    
    func updateSearchButtonStyle(enabled: Bool) {
        let button = inviteCodeView.searchButtonView
        
        var config = button.configuration
        config?.baseBackgroundColor = enabled ? .primary500 : .gray300
        config?.baseForegroundColor = enabled ? .white : .gray500
        
        button.configuration = config
    }
    
    @objc func workplaceSelectViewDidTap() {
        let workplaceListVC = WorkplaceListViewController()
        navigationController?.pushViewController(workplaceListVC, animated: true)
    }
    
    @objc func searchButtonDidTap() {
        switch currentState {
        case .input:
            // TODO: 서버에 초대코드로 근무지 조회
            print("조회하기")
            updateState(to: .result)
            
        case .result:
            // TODO: 등록 동작
            print("등록하기")
            navigationController?.popViewController(animated: true)
        }
    }
}
