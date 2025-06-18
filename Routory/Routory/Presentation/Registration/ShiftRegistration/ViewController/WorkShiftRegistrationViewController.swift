//
//  WorkShiftRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import RxSwift

// MARK: - WorkShiftRegistrationViewController

final class WorkShiftRegistrationViewController: UIViewController,UIGestureRecognizerDelegate {
    
    weak var delegate: RegistrationVCDelegate?

    private let scrollView = UIScrollView()
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
            guard let self = self else {
                return
            }

            self.setupUI()
            self.setupNavigationBar()
            self.layout()

            self.keyboardHandler = KeyboardInsetHandler(
                scrollView: self.scrollView,
                containerView: self.view,
                targetView: self.contentView.memoBoxView
            )
            self.keyboardHandler?.startObserving()
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

    private func setupNavigationBar() {
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(navigationBar)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        delegateHandler = ShiftRegistrationDelegateHandler(
             contentView: contentView,
             navigationController: navigationController,
             viewModel: viewModel
         )
         actionHandler = RegistrationActionHandler(
             contentView: contentView,
             navigationController: navigationController
         )

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

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.frameLayoutGuide).inset(16)
        }
    }
    
    @objc func didTapRegister() {
        print("근무 등록 데이터")
//        print("근무지: ",contentView.simpleRowView.getData())
//        print("근무 날짜 - 날짜: ",contentView.workDateView.getdateRowData())
//        print("근무 날짜 - 반복: ",contentView.workDateView.getrepeatRowData())
//        print("근무 시간 - 출근: ",contentView.workTimeView.getstartRowData())
//        print("근무 시간 - 퇴근: ",contentView.workTimeView.getendRowData())
//        print("근무 시간 - 휴게: ",contentView.workTimeView.getrestRowData())
//        print("루틴: ",contentView.routineView.getSelectedRoutineIDs())
//        print("메모: ",contentView.memoBoxView.getData())
        
        let workPlace = contentView.simpleRowView.getData()
        let workPlaceID = contentView.simpleRowView.getID()
        let eventDate = contentView.workDateView.getdateRowData()
        let startTime = contentView.workTimeView.getstartRowData()
        let endTime = contentView.workTimeView.getendRowData()
        let breakTime = contentView.workTimeView.getrestRowData()
        let routineIDs = contentView.routineView.getSelectedRoutineIDs()
        let repeatDays = contentView.workDateView.getRepeatData()
        let memo = contentView.memoBoxView.getData()
        
        guard let dateComponents = parseDateComponents(from: eventDate) else {
            print("날짜 파싱 실패: \(eventDate)")
            return
        }

        let event = CalendarEvent(
            title: "",
            eventDate: eventDate,
            startTime: startTime,
            endTime: endTime,
            createdBy: "",
            year: dateComponents.year,
            month: dateComponents.month,
            day: dateComponents.day,
            routineIds: routineIDs,
            repeatDays: repeatDays,
            memo: memo
        )

        print(workPlaceID,event)
    }
}
