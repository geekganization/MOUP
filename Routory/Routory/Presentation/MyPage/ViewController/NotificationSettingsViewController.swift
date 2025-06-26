//
//  NotificationSettingsViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/17/25.
//

import UIKit
import Then
import SnapKit

final class NotificationSettingsViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let notificationSettingsView = NotificationSettingsView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = notificationSettingsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension NotificationSettingsViewController {
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
        notificationSettingsView.navigationBarView.backButtonView.addTarget(
            self,
            action: #selector(backButtonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
}
