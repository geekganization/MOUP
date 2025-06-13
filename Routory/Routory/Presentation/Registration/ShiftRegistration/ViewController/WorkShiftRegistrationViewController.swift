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
    private var delegateHandler: ShiftRegistrationDelegateHandler?
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

        delegateHandler = ShiftRegistrationDelegateHandler(contentView: contentView, navigationController: navigationController)
        actionHandler = RegistrationActionHandler(contentView: contentView, navigationController: navigationController)

        contentView.simpleRowView.delegate = delegateHandler
        contentView.routineView.delegate = delegateHandler
        contentView.labelView.delegate = delegateHandler
        contentView.workDateView.delegate = delegateHandler
        contentView.workTimeView.delegate = delegateHandler
        
        contentView.workerSelectionView.isHidden = true
        contentView.labelView.isHidden = true

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
    
    @objc func didTapRegister() {
        print("근무 등록 데이터")
        print("근무지: ",contentView.simpleRowView.getData())
        print("근무 날짜 - 날짜: ",contentView.workDateView.getdateRowData())
        print("근무 날짜 - 반복: ",contentView.workDateView.getrepeatRowData())
        print("근무 시간 - 출근: ",contentView.workTimeView.getstartRowData())
        print("근무 시간 - 퇴근: ",contentView.workTimeView.getendRowData())
        print("근무 시간 - 휴게: ",contentView.workTimeView.getrestRowData())
        print("루틴: ",contentView.routineView.getTitleData())
        print("메모: ",contentView.memoBoxView.getData())
    }
}
