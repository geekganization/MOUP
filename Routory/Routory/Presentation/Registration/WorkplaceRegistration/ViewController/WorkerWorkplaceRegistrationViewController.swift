//
//  WorkerWorkplaceRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/13/25.
//

import UIKit
import SnapKit
import Then

final class WorkerWorkplaceRegistrationViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = WorkplaceRegistrationContentView()

    private var delegateHandler: WorkplaceRegistrationDelegateHandler?
    private var actionHandler: RegistrationActionHandler?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        layout()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        configureShiftNavigationBar(
            for: self,
            title: "새 근무지 등록",
            target: self,
            action: #selector(didTapBack)
        )
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        delegateHandler = WorkplaceRegistrationDelegateHandler(contentView: contentView, navigationController: navigationController)
        actionHandler = RegistrationActionHandler(contentView: contentView, navigationController: navigationController)

        contentView.salaryInfoView.delegate = delegateHandler
        contentView.workplaceInfoView.delegate = delegateHandler
        contentView.labelView.delegate = delegateHandler

        contentView.registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        contentView.registerButton.addTarget(actionHandler, action: #selector(RegistrationActionHandler.buttonTouchDown(_:)), for: .touchDown)
        contentView.registerButton.addTarget(actionHandler, action: #selector(RegistrationActionHandler.buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func layout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.frameLayoutGuide).inset(16)
        }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapRegister() {
        print("이름:", contentView.workplaceInfoView.getName())
        print("카테고리:", contentView.workplaceInfoView.getCategory())
        print("급여 유형:", contentView.salaryInfoView.getTypeValue())
        print("급여 계산:", contentView.salaryInfoView.getCalcValue())
        print("고정급:", contentView.salaryInfoView.getFixedSalaryValue())
        print("급여일:", contentView.salaryInfoView.getPayDateValue())
        print("근무 조건:", contentView.workConditionView.getSelectedConditions())
        print("라벨:", contentView.labelView.getColorLabelData())
    }
}
