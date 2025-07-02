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
    
    // MARK: - Properties
    
    private var hasAnimatedIn = false
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasAnimatedIn {
            hasAnimatedIn = true
            animateModalIn()
        }
    }
}

private extension WorkplaceAddModalViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        updateUIBasedOnUserRole()
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
            self?.animateModalOut {
                self?.dismiss(animated: false)
            }
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
            return WorkerWorkplaceRegistrationViewController(
                workplaceId: "",
                isRegisterMode: true,
                isEdit: false,
                isHideWorkplaceInfoViewArrow: false,
                mode: .fullRegistration,
                
                nameValue: "",
                categoryValue: "편의점",
                
                salaryTypeValue: "매월",
                salaryCalcValue: "고정",
                fixedSalaryValue: "2,000,000",
                hourlyWageValue: "12,000",
                payDateValue: "15일",
                payWeekdayValue: "금요일",
                
                isFourMajorSelected: false,
                isNationalPensionSelected: false,
                isHealthInsuranceSelected: false,
                isEmploymentInsuranceSelected: false,
                isIndustrialAccidentInsuranceSelected: false,
                isIncomeTaxSelected: false,
                isWeeklyAllowanceSelected: false,
                isNightAllowanceSelected: false,

                labelTitle: "노란색",
                showDot: true,
                dotColor: .systemYellow
            )
        case .owner:
            return OwnerWorkplaceRegistrationViewController(
                isRegisterMode: true,
                isEdit: false,
                nameValue: "",
                categoryValue: "편의점",
                
                salaryTypeValue: "매월",
                salaryCalcValue: "고정",
                fixedSalaryValue: "2,000,000",
                hourlyWageValue: "12,000",
                payDateValue: "15일",
                payWeekdayValue: "금요일",
                
                isFourMajorSelected: true,
                isNationalPensionSelected: false,
                isHealthInsuranceSelected: true,
                isEmploymentInsuranceSelected: true,
                isIndustrialAccidentInsuranceSelected: false,
                isIncomeTaxSelected: true,
                isWeeklyAllowanceSelected: false,
                isNightAllowanceSelected: true,
                
                labelTitle: "노란색",
                showDot: true,
                dotColor: .systemYellow
            )
        }
    }
    
    @objc func backgroundDidTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        if workplaceAddView.frame.contains(location) == false {
            animateModalOut {
                self.dismiss(animated: false)
            }
        }
    }
    
    func updateUIBasedOnUserRole() {
        UserManager.shared.getUser { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let user):
                if UserType(role: user.role) == .owner {
                    self.workplaceAddView.updateLayoutForOwner()
                    self.updateWorkplaceAddViewHeight(to: 174)
                    self.view.layoutIfNeeded()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateWorkplaceAddViewHeight(to height: CGFloat) {
        workplaceAddView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }
    
    func animateModalIn() {
        workplaceAddView.transform = CGAffineTransform(
            translationX: 0,
            y: workplaceAddView.frame.height
        )
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
            self.workplaceAddView.transform = .identity
        }
    }
    
    func animateModalOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.workplaceAddView.transform = CGAffineTransform(translationX: 0, y: self.workplaceAddView.frame.height)
        }, completion: { _ in
            completion?()
        })
    }
}
