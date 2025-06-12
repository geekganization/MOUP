//
//  AccountViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/11/25.
//

import UIKit

final class AccountViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let accountView = AccountView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = accountView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension AccountViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setActions()
    }
    
    // MARK: - setStyles
    func setStyles() {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - setActions
    func setActions() {
        accountView.navigationBarView.backButtonView.addTarget(
            self,
            action: #selector(backButonDidTap),
            for: .touchUpInside
        )
        
        accountView.onDeleteAccountTapped = { [weak self] in
            let deleteModalVC = DeleteAccountModalViewController()
            deleteModalVC.modalPresentationStyle = .overFullScreen
            deleteModalVC.modalTransitionStyle = .crossDissolve
            self?.present(deleteModalVC, animated: true, completion: nil)
        }
    }
    
    @objc func backButonDidTap() {
        navigationController?.popViewController(animated: true)
    }
}
