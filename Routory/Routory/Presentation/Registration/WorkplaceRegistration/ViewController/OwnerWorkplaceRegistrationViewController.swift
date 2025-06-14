//
//  OwnerWorkplaceRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/14/25.
//

import UIKit
import SnapKit
import Then

final class OwnerWorkplaceRegistrationViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = WorkplaceRegistrationContentView(workplaceTitle: "매장 *")

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
            title: "새 매장 등록",
            target: self,
            action: #selector(didTapBack)
        )
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.salaryInfoView.isHidden = true
        contentView.workConditionView.isHidden = true

        delegateHandler = WorkplaceRegistrationDelegateHandler(contentView: contentView, navigationController: navigationController)

        contentView.workplaceInfoView.delegate = delegateHandler
        contentView.labelView.delegate = delegateHandler

        actionHandler = RegistrationActionHandler(contentView: contentView, navigationController: navigationController)
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
        print("사장님 새 근무지 등록 데이터")
        print("이름:", contentView.workplaceInfoView.getName())
        print("카테고리:", contentView.workplaceInfoView.getCategory())
        print("라벨:", contentView.labelView.getColorLabelData())
    }
}
