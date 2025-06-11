//
//  DeleteAccountModalViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/11/25.
//

import UIKit
import SnapKit
import Then

final class DeleteAccountModalViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let deleteAccountModal = DeleteAccountModal().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}

private extension DeleteAccountModalViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubview(deleteAccountModal)
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .background
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        deleteAccountModal.snp.makeConstraints {
            $0.height.equalTo(348)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    // MARK: - setActions
    func setActions() {
        deleteAccountModal.onRequestDismiss = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
