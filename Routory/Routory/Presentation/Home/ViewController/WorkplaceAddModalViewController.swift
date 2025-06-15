//
//  WorkplaceAddViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/13/25.
//

import UIKit
import Then
import SnapKit

final class WorkplaceAddModalViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let workplaceAddView = WorkplaceAddModalView().then {
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

private extension WorkplaceAddModalViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubviews(workplaceAddView)
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .background
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        workplaceAddView.snp.makeConstraints {
            $0.height.equalTo(227)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    // MARK: - setActions
    func setActions() {
        workplaceAddView.onDismiss = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        workplaceAddView.inviteCodeButtonView.addTarget(
            self,
            action: #selector(inviteCodeButtonDidTap),
            for: .touchUpInside
        )
        
        workplaceAddView.manualInputButtonView.addTarget(
            self,
            action: #selector(manualInputButtonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func inviteCodeButtonDidTap() {
        print("초대 코드 입력하기")
    }
    
    @objc func manualInputButtonDidTap() {
        print("직접 입력하기")
    }
}
