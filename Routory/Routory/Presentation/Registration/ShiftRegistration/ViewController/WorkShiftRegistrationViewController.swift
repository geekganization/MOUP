//
//  WorkShiftRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit

// MARK: - WorkShiftRegistrationViewController

final class WorkShiftRegistrationViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = ShiftRegistrationContentView()
    private var delegateHandler: RegistrationDelegateHandler?
    private var actionHandler: RegistrationActionHandler?
    private var keyboardHandler: KeyboardInsetHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        layout()

        keyboardHandler = KeyboardInsetHandler(scrollView: scrollView, containerView: view,targetView: contentView.memoBoxView)
        keyboardHandler?.startObserving()
    }

    deinit {
        keyboardHandler?.stopObserving()
    }

    private func setupNavigationBar() {
        configureShiftNavigationBar(
            for: self,
            title: "근무 등록",
            target: actionHandler as Any,
            action: #selector(RegistrationActionHandler.didTapBack)
        )
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        delegateHandler = RegistrationDelegateHandler(contentView: contentView, navigationController: navigationController)
        actionHandler = RegistrationActionHandler(contentView: contentView, navigationController: navigationController)

        contentView.simpleRowView.delegate = delegateHandler
        contentView.routineView.delegate = delegateHandler
        contentView.labelView.delegate = delegateHandler
        contentView.workDateView.delegate = delegateHandler
        contentView.workTimeView.delegate = delegateHandler
        
        contentView.workerSelectionView.isHidden = true
        contentView.labelView.isHidden = true

        contentView.registerButton.addTarget(actionHandler, action: #selector(RegistrationActionHandler.didTapRegister), for: .touchUpInside)
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
}
