//
//  OwnerShiftRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit
import SnapKit
import RxSwift

final class OwnerShiftRegistrationViewController: UIViewController,UIGestureRecognizerDelegate {
    
    weak var delegate: RegistrationVCDelegate?

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
    
    fileprivate lazy var navigationBar = BaseNavigationBar(title: "근무 등록") //*2
    let disposeBag = DisposeBag()
    
    private let viewModel = WorkplaceListViewModel(workplaceUseCase: WorkplaceUseCase(repository: WorkplaceRepository(service: WorkplaceService())))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchWorkplaces { [weak self] in
            guard let self = self else { return }

            self.setupUI()
            self.setupNavigationBar()
            self.layout()
            self.setupSegment()
            self.setupKeyboardHandler()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            delegate?.registrationVCIsMovingFromParent()
        }
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
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = .white

        scrollView.keyboardDismissMode = .interactive
        view.addSubview(navigationBar)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.addArrangedSubview(headerSegment)
        stackView.addArrangedSubview(contentView)
        
        stackView.setCustomSpacing(24, after: headerSegment)

        contentView.simpleRowView.isHidden = true

        delegateHandler = ShiftRegistrationDelegateHandler(
            contentView: contentView,
            navigationController: navigationController,
            viewModel: viewModel
        )
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
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide) 
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
        let workPlace = contentView.simpleRowView.getData()
        let workPlaceID = contentView.simpleRowView.getID()
        let eventDate = contentView.workDateView.getdateRowData()
        let startTime = contentView.workTimeView.getstartRowData()
        let endTime = contentView.workTimeView.getendRowData()
        let breakTime = contentView.workTimeView.getrestRowData()
        let repeatDays = contentView.workDateView.getRepeatData()
        let memo = contentView.memoBoxView.getData()
        
        guard let dateComponents = parseDateComponents(from: eventDate) else {
            print("날짜 파싱 실패: \(eventDate)")
            return
        }
        
        switch registrationMode {
        case .owner:
            print("사장님 새 근무 등록 데이터 - 사장님")
            print("근무지: ", workPlace)
            print("근무 날짜 - 날짜: ", eventDate)
            print("근무 날짜 - 반복: ", repeatDays)
            print("근무 시간 - 출근: ", startTime)
            print("근무 시간 - 퇴근: ", endTime)
            print("근무 시간 - 휴게: ", breakTime)
            
            let routineIDs = contentView.routineView.getSelectedRoutineIDs()
            print("루틴: ", routineIDs)
            print("메모: ", memo)
            
            let event = CalendarEvent(
                title: "",
                eventDate: eventDate,
                startTime: startTime,
                endTime: endTime,
                createdBy: "owner",
                year: dateComponents.year,
                month: dateComponents.month,
                day: dateComponents.day,
                routineIds: routineIDs,
                repeatDays: repeatDays,
                memo: memo
            )
            print(workPlaceID,event)

        case .employee:
            print("사장님 새 근무 등록 데이터 - 알바생")
            print("근무지: ", workPlace)
            let worker = contentView.workerSelectionView.getSelectedWorkerData()
            print("근무자: ", worker)
            print("근무 날짜 - 날짜: ", eventDate)
            print("근무 날짜 - 반복: ", repeatDays)
            print("근무 시간 - 출근: ", startTime)
            print("근무 시간 - 퇴근: ", endTime)
            print("근무 시간 - 휴게: ", breakTime)
            print("메모: ", memo)
            
            let event = CalendarEvent(
                title: "",
                eventDate: eventDate,
                startTime: startTime,
                endTime: endTime,
                createdBy: "",
                year: dateComponents.year,
                month: dateComponents.month,
                day: dateComponents.day,
                routineIds: [],
                repeatDays: repeatDays,
                memo: memo
            )
            print(workPlaceID,event)
        }
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
