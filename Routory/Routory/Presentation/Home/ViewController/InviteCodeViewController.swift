//
//  InviteCodeViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/16/25.
//

import UIKit

final class InviteCodeViewController: UIViewController {
    
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
        inviteCodeView.codeTextFieldView.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
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
}
