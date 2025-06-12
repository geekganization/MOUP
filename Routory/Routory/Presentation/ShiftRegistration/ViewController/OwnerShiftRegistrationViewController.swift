//
//  OwnerShiftRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit
import SnapKit

final class OwnerShiftRegistrationViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let headerSegment = UISegmentedControl(items: ["사장님", "알바생"])
    private let contentView = ShiftRegistrationContentView()
    private var delegateHandler: ShiftRegistrationDelegateHandler?
    private var actionHandler: ShiftRegistrationActionHandler?
    private var keyboardHandler: KeyboardInsetHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        layout()

        keyboardHandler = KeyboardInsetHandler(
            scrollView: scrollView,
            containerView: view,
            targetView: contentView.memoBoxView
        )
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
            action: #selector(ShiftRegistrationActionHandler.didTapBack)
        )
    }

    private func setupUI() {
        view.backgroundColor = .white

        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.addArrangedSubview(headerSegment)
        stackView.addArrangedSubview(contentView)

        contentView.simpleRowView.isHidden = true

        delegateHandler = ShiftRegistrationDelegateHandler(contentView: contentView, navigationController: navigationController)
        actionHandler = ShiftRegistrationActionHandler(contentView: contentView, navigationController: navigationController)

        contentView.routineView.delegate = delegateHandler
        contentView.labelView.delegate = delegateHandler
        contentView.workDateView.delegate = delegateHandler
        contentView.workTimeView.delegate = delegateHandler
        contentView.workerSelectionView.delegate = delegateHandler

        contentView.registerButton.addTarget(actionHandler, action: #selector(ShiftRegistrationActionHandler.didTapRegister), for: .touchUpInside)
        contentView.registerButton.addTarget(actionHandler, action: #selector(ShiftRegistrationActionHandler.buttonTouchDown(_:)), for: .touchDown)
        contentView.registerButton.addTarget(actionHandler, action: #selector(ShiftRegistrationActionHandler.buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func layout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.frameLayoutGuide).inset(16)
        }
    }
}
