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
    private let headerSegment = UISegmentedControl(items: ["사장님", "알바생"]).then {
        $0.selectedSegmentIndex = 0
        $0.backgroundColor = UIColor.gray300

        $0.setTitleTextAttributes([
            .foregroundColor: UIColor.gray500,
            .font: UIFont.bodyMedium(16)
        ], for: .normal)

        $0.setTitleTextAttributes([
            .foregroundColor: UIColor.primary500,
            .font: UIFont.bodyMedium(16)
        ], for: .selected)
        
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1.0
    }
    private var registrationMode: ShiftRegistrationMode = .owner
    private let contentView = ShiftRegistrationContentView()
    private var delegateHandler: ShiftRegistrationDelegateHandler?
    private var actionHandler: RegistrationActionHandler?
    private var keyboardHandler: KeyboardInsetHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        layout()
        setupSegment()
        setupKeyboardHandler()
    }

    deinit {
        keyboardHandler?.stopObserving()
    }
    
    private func setupKeyboardHandler() {
        keyboardHandler = KeyboardInsetHandler(
            scrollView: scrollView,
            containerView: view,
            targetView: contentView.memoBoxView
        )
        keyboardHandler?.startObserving()
    }
    
    private func setupSegment() {
        headerSegment.selectedSegmentIndex = 0
        headerSegment.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
        didChangeSegment(headerSegment)
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

        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.addArrangedSubview(headerSegment)
        stackView.addArrangedSubview(contentView)
        
        stackView.setCustomSpacing(24, after: headerSegment)

        contentView.simpleRowView.isHidden = true

        delegateHandler = ShiftRegistrationDelegateHandler(contentView: contentView, navigationController: navigationController)
        actionHandler = RegistrationActionHandler(contentView: contentView, navigationController: navigationController)

        contentView.simpleRowView.delegate = delegateHandler
        contentView.routineView.delegate = delegateHandler
        contentView.labelView.delegate = delegateHandler
        contentView.workDateView.delegate = delegateHandler
        contentView.workTimeView.delegate = delegateHandler
        contentView.workerSelectionView.delegate = delegateHandler

        contentView.registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        contentView.registerButton.addTarget(actionHandler, action: #selector(RegistrationActionHandler.buttonTouchDown(_:)), for: .touchDown)
        contentView.registerButton.addTarget(actionHandler, action: #selector(RegistrationActionHandler.buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func layout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.frameLayoutGuide).inset(16)
        }
        
        headerSegment.snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }
    
    @objc func didTapRegister() {
        print("근무지: ",contentView.simpleRowView.getData())
        print("근무자: ",contentView.workerSelectionView.getSelectedWorkerData())
        print("근무 날짜 - 날짜: ",contentView.workDateView.getdateRowData())
        print("근무 날짜 - 반복: ",contentView.workDateView.getrepeatRowData())
        print("근무 시간 - 출근: ",contentView.workTimeView.getstartRowData())
        print("근무 시간 - 퇴근: ",contentView.workTimeView.getendRowData())
        print("근무 시간 - 휴게: ",contentView.workTimeView.getrestRowData())
        print("루틴: ",contentView.routineView.getTitleData())
        print("색깔: ",contentView.labelView.getColorLabelData())
        print("메모: ",contentView.memoBoxView.getData())
    }
    
    @objc private func didChangeSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            registrationMode = .owner
            contentView.simpleRowView.isHidden = false
            contentView.workerSelectionView.isHidden = true
            contentView.labelView.isHidden = true
        case 1:
            registrationMode = .employee
            contentView.simpleRowView.isHidden = false
            contentView.workerSelectionView.isHidden = false
            contentView.labelView.isHidden = true
            contentView.routineView.isHidden = true
        default:
            break
        }
    }
}
