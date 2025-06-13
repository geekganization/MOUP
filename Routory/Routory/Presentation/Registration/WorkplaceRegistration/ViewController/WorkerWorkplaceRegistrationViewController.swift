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

    // 예: KeyboardInsetHandler, ActionHandler 등이 있다면 여기에 선언 가능

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

        contentView.registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
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

    @objc private func didTapRegister() {
        print("등록 버튼 탭됨")
    }
}
