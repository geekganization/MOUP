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
        view.backgroundColor = .modalBackground
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
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(backgroundDidTap(_:))
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func inviteCodeButtonDidTap() {
        let vc = InviteCodeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func manualInputButtonDidTap() {
        UserManager.shared.getUser { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                switch UserType(role: user.role) {
                case .worker:
                    let vc = self.makeManualWorkplaceRegistrationVC(type: .worker)
                    self.navigationController?.pushViewController(vc, animated: true)
                case .owner:
                    let vc = self.makeManualWorkplaceRegistrationVC(type: .owner)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func makeManualWorkplaceRegistrationVC(type: UserType) -> UIViewController {
        switch type {
        case .worker:
            return WorkerWorkplaceRegistrationViewController(mode: .fullRegistration)
        case .owner:
            return OwnerWorkplaceRegistrationViewController()
        }
    }
    
    @objc func backgroundDidTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        if workplaceAddView.frame.contains(location) == false {
            dismiss(animated: true)
        }
    }
}
