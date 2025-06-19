//
//  ShareInviteCodeViewController.swift
//  Routory
//
//  Created by 송규섭 on 6/19/25.
//

import UIKit

class ShareInviteCodeViewController: UIViewController {

    // MARK: - UI Components

    private let shareInviteCodeView = ShareInviteCodeView().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        $0.layer.masksToBounds = true
        $0.backgroundColor = .primaryBackground
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension ShareInviteCodeViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubviews(shareInviteCodeView)
    }

    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .modalBackground
    }

    // MARK: - setConstraints
    func setConstraints() {
        shareInviteCodeView.snp.makeConstraints {
            $0.height.equalTo(249)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }

    // MARK: - setActions
    func setActions() {
        shareInviteCodeView.onDismiss = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        shareInviteCodeView.didTapCopyInviteCodeBtn = { [weak self] in
            let inviteCode = self?.shareInviteCodeView.getInviteCode()

            UIPasteboard.general.string = inviteCode

            
        }
    }

    @objc func inviteCodeButtonDidTap() {
        let vc = InviteCodeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func manualInputButtonDidTap() {
        let vc = WorkerWorkplaceRegistrationViewController(mode: .fullRegistration)
        navigationController?.pushViewController(vc, animated: true)
    }
}
