//
//  ShareInviteCodeViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/19/25.
//

import UIKit
import Then
import SnapKit

final class ShareInviteCodeViewController: UIViewController {

    // MARK: - UI Components
    
    private let shareInviteCodeView = ShareInviteCodeView().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        $0.layer.masksToBounds = true
        $0.backgroundColor = .white
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
            $0.height.equalTo(227)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    // MARK: - setActions
    func setActions() {
        shareInviteCodeView.onDismiss = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
