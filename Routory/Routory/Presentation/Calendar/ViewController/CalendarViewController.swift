//
//  CalendarViewController.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit
import OSLog

import BetterSegmentedControl
import JTAppleCalendar
import RxCocoa
import RxSwift
import SnapKit
import Then

final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let viewModel: CalendarViewModel
    
    private let disposeBag = DisposeBag()
    
    private var output: CalendarViewModel.Output
    
    private let calendarModeRelay = BehaviorRelay<CalendarMode>(value: .personal)
    private let filterModelRelay = BehaviorRelay<FilterModel?>(value: nil)
    private let searchRoutineIdRelay = PublishRelay<String>()
    
    private var currCalendar = Calendar.current
    
    private var personalEventDataSource: [Date: [CalendarModel]] = [:]
    private var sharedEventDataSource: [Date: [CalendarModel]] = [:]
    
    private let visibleYearMonth: BehaviorRelay<(year: Int, month: Int)>
    private var selectedDate: Date?
    private var pendingEventSelection: (selectedDate: Date, model: CalendarModel, isEdit: Bool)?
    
    // MARK: - UI Components
    
    private lazy var onboardingView = OnboardingView(mode: .calendar)
    
    private let calendarView = CalendarView()
    
    // MARK: - Initializer
    
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        self.currCalendar.timeZone = .autoupdatingCurrent
        visibleYearMonth = BehaviorRelay(value: (year: currCalendar.component(.year, from: .now),
                                                 month: currCalendar.component(.month, from: .now)))
        let input = CalendarViewModel.Input(loadMonthEvent: visibleYearMonth.asObservable(),
                                            calendarMode: calendarModeRelay.asObservable(),
                                            filterModel: filterModelRelay.asObservable(),
                                            searchRoutineId: searchRoutineIdRelay.asObservable())
        self.output = viewModel.tranform(input: input)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = calendarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCalendar()
        
        // 온보딩 확인 및 표시
        if !OnboardingManager.hasSeenOnboardingCalendar {
            showOnboarding()
        }
    }
}

// MARK: - UI Methods

private extension CalendarViewController {
    func configure() {
        setStyles()
        setDelegates()
        setActions()
        setBinding()
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func setDelegates() {
        calendarView.getJTACalendar.calendarDataSource = self
        calendarView.getJTACalendar.calendarDelegate = self
    }
    
    func setActions() {
        // 네비게이션 바 "오늘" 버튼
        calendarView.getNavigationBar.rx.rightBtnTapped
            .subscribe(with: self) { owner, _ in
                owner.deselectCell()
                owner.calendarView.getJTACalendar.scrollToDate(.now, animateScroll: true)
            }.disposed(by: disposeBag)
        
        let todayButtonAction = UIAction(handler: { [weak self] _ in
            self?.deselectCell()
            self?.calendarView.getJTACalendar.scrollToDate(.now, animateScroll: true)
        })
        let todayButton = UIBarButtonItem(title: "오늘", primaryAction: todayButtonAction)
        todayButton.setTitleTextAttributes([.font: UIFont.headBold(14), .foregroundColor: UIColor.gray900], for: .normal)
        todayButton.setTitleTextAttributes([.font: UIFont.headBold(14), .foregroundColor: UIColor.gray900], for: .selected)
        self.navigationItem.rightBarButtonItem = todayButton
        
        // CalendarEventListVC 모달 이외 영역 터치
        let calendarViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didCalendarViewTap(_:)))
        calendarViewTapRecognizer.cancelsTouchesInView = false
        calendarView.addGestureRecognizer(calendarViewTapRecognizer)
        
        // 캘린더 연/월 이동 피커
        calendarView.getCalendarHeaderView.getYearMonthButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.didYearMonthButtonTap()
            }.disposed(by: disposeBag)
        
        // 개인/공유 캘린더 토글 스위치
        calendarView.getCalendarHeaderView.getToggleSwitch.addAction(UIAction(handler: { [weak self] action in
            self?.deselectCell()
            
            guard let sender = action.sender as? BetterSegmentedControl else { return }
            self?.calendarModeRelay.accept(CalendarMode.allCases[sender.index])
        }), for: .valueChanged)
    }
    
    func setBinding() {
        // 캘린더 모드(개인/공유)
        calendarModeRelay
            .subscribe(with: self) { owner, mode in
                owner.calendarView.getJTACalendar.reloadData()
            }.disposed(by: disposeBag)
        
        // 근무지/매장 필터 버튼
        calendarView.getCalendarHeaderView.getFilterButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.didFilterButtonTap()
            }.disposed(by: disposeBag)
        
        
        // MARK: - Output (ViewModel ➡️ ViewController)
        
        output.calendarModelListRelay
            .asDriver(onErrorJustReturn: ([], []))
            .drive(with: self) { owner, calendarModelList in
                owner.populateDataSource(calendarModelLists: calendarModelList)
            }.disposed(by: disposeBag)
        
        output.searchedRoutineTitleRelay
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, routineTitle in
                guard let pending = owner.pendingEventSelection else { return }
                owner.presentRegisterVC(date: pending.selectedDate,
                                        model: pending.model,
                                        routineTitle: routineTitle,
                                        isRegister: false,
                                        isEdit: pending.isEdit)
            }.disposed(by: disposeBag)
    }
}

// MARK: - Private Methods

private extension CalendarViewController {
    func showOnboarding() {
        didSelectCell(day: 1, calendarModelList: [], animated: false) {
            if let nav = self.presentedViewController as? UINavigationController,
               let calendarEventListVC = nav.viewControllers.first as? CalendarEventListViewController {
                
                let onboardingModalVC = OnboardingViewController(mode: .calendar)
                onboardingModalVC.delegate = self
                onboardingModalVC.modalPresentationStyle = .overFullScreen
                onboardingModalVC.modalTransitionStyle = .crossDissolve
                calendarEventListVC.present(onboardingModalVC, animated: true)
            }
        }
    }
    
    func didYearMonthButtonTap() {
        deselectCell()
        
        guard let config = calendarView.getCalendarHeaderView.getYearMonthButton.configuration,
              let title = config.title,
              let currYear = Int(title.prefix(4)),
              let currMonth = Int(title.suffix(2)) else { return }
        
        let pickerModalVC = BasePickerViewController(mode: .yearMonth, currYear: currYear, currMonth: currMonth)
        pickerModalVC.yearMonthPickerdelegate = self
        
        if let sheet = pickerModalVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
        
        self.present(pickerModalVC, animated: true)
    }
    
    func presentRegisterVC(date: Date, model: CalendarModel?, routineTitle: String?, isRegister: Bool, isEdit: Bool) {
        UserManager.shared.getUser { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                if isRegister {
                    // 근무 등록
                    let currentHour = currCalendar.component(.hour, from: .now)
                    if user.role == UserRole.worker.rawValue {
                        // 알바생
                        let workShiftRegisterVC = WorkShiftRegistrationViewController(
                            isRegisterMode: true,
                            isRead: false,
                            eventId: "",
                            editWorkplaceId: "",
                            workPlaceTitle: "근무지 선택 *",
                            workerTitle: "",
                            routineTitle: "루틴 추가",
                            editRoutineIDs: [],
                            dateValue: DateFormatter.dataSourceDateFormatter.string(from: date),
                            repeatValue: "없음",
                            startTime: "\(String(format: "%02d", currentHour)):00",
                            endTime: "\(String(format: "%02d", currentHour + 1)):00",
                            restTime: "없음",
                            memoPlaceholder: "추가적인 내용을 입력해주세요"
                        )
                        workShiftRegisterVC.hidesBottomBarWhenPushed = true
                        workShiftRegisterVC.delegate = self
                        
                        self.navigationController?.pushViewController(workShiftRegisterVC, animated: true)
                        self.navigationController?.presentedViewController?.dismiss(animated: true)
                    } else {
                        // 사장님
                        let ownerShiftRegisterVC = OwnerShiftRegistrationViewController(
                            isRegisterMode: true,
                            isEdit: true,
                            eventId: "",
                            editWorkplaceId: "",
                            workPlaceTitle: "매장 선택",
                            workerTitle: "알바 선택",
                            routineTitle: "루틴 추가",
                            editRoutineIDs: [],
                            dateValue: DateFormatter.dataSourceDateFormatter.string(from: date),
                            repeatValue: "없음",
                            startTime: "\(String(format: "%02d", currentHour)):00",
                            endTime: "\(String(format: "%02d", currentHour + 1)):00",
                            restTime: "없음",
                            memoPlaceholder: "추가적인 내용을 입력해주세요"
                        )
                        ownerShiftRegisterVC.hidesBottomBarWhenPushed = true
                        ownerShiftRegisterVC.delegate = self
                        
                        self.navigationController?.pushViewController(ownerShiftRegisterVC, animated: true)
                        self.navigationController?.presentedViewController?.dismiss(animated: true)
                    }
                } else {
                    // 근무 수정
                    guard let model, let routineTitle else { return }
                    let event = model.eventInfo.calendarEvent
                    let repeatValue = event.repeatDays.isEmpty ? "없음" : event.repeatDays.joined(separator: ", ")
                    let restTime = model.breakTimeMinutes.displayString
                    if user.role == UserRole.worker.rawValue {
                        // 알바생
                        let workShiftRegisterVC = WorkShiftRegistrationViewController(
                            isRegisterMode: false,
                            isRead: !isEdit,
                            eventId: model.eventInfo.id,
                            editWorkplaceId: model.workplaceId,
                            workPlaceTitle: model.workplaceName,
                            workerTitle: model.workerName,
                            routineTitle: "\(routineTitle)" + (event.routineIds.count > 1 ? " 외 \(event.routineIds.count - 1)개" : ""),
                            editRoutineIDs: event.routineIds,
                            dateValue: DateFormatter.dataSourceDateFormatter.string(from: date),
                            repeatValue: repeatValue,
                            startTime: event.startTime,
                            endTime: event.endTime,
                            restTime: restTime,
                            memoPlaceholder: event.memo
                        )
                        workShiftRegisterVC.hidesBottomBarWhenPushed = true
                        workShiftRegisterVC.delegate = self
                        
                        self.navigationController?.pushViewController(workShiftRegisterVC, animated: true)
                        self.navigationController?.presentedViewController?.dismiss(animated: true)
                    } else {
                        // 사장님
                        let ownerShiftRegisterVC = OwnerShiftRegistrationViewController(
                            isRegisterMode: false,
                            isEdit: isEdit,
                            eventId: model.eventInfo.id,
                            editWorkplaceId: model.workplaceId,
                            workPlaceTitle: model.workplaceName,
                            workerTitle: model.workerName,
                            routineTitle: routineTitle,
                            editRoutineIDs: event.routineIds,
                            dateValue: DateFormatter.dataSourceDateFormatter.string(from: date),
                            repeatValue: repeatValue,
                            startTime: event.startTime,
                            endTime: event.endTime,
                            restTime: restTime,
                            memoPlaceholder: event.memo
                        )
                        ownerShiftRegisterVC.hidesBottomBarWhenPushed = true
                        ownerShiftRegisterVC.delegate = self
                        
                        self.navigationController?.pushViewController(ownerShiftRegisterVC, animated: true)
                        self.navigationController?.presentedViewController?.dismiss(animated: true)
                    }
                }
            case .failure(let error):
                self.logger.error("\(error.localizedDescription)")
            }
        }
    }
}

// MARK: - @objc Methods

@objc private extension CalendarViewController {
    func didCalendarViewTap(_ sender: UITapGestureRecognizer) {
        deselectCell()
    }
}

// MARK: - CalendarView Methods

private extension CalendarViewController {
    /// `CalendarDayCell`의 셀을 탭했을 때 호출하는 메서드
    ///
    /// - Parameters:
    ///   - day: 탭한 셀의 일
    ///   - eventList: 탭한 셀의 일에 해당하는 `CalendarEvent` 배열
    func didSelectCell(day: Int, calendarModelList: [CalendarModel], animated: Bool = true, completion: (() -> Void)? = nil) {
        let calendarService = CalendarService()
        let calendarRepository = CalendarRepository(calendarService: calendarService)
        let calendarUseCase = CalendarUseCase(repository: calendarRepository)
        let calendarEventListVM = CalendarEventListViewModel(calendarUseCase: calendarUseCase, calendarModelList: calendarModelList)
        let calendarEventListVC = CalendarEventListViewController(viewModel: calendarEventListVM, day: day, calendarMode: calendarModeRelay.value)
        calendarEventListVC.delegate = self
        
        let modalNC = UINavigationController(rootViewController: calendarEventListVC)
        
        if let sheet = modalNC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 0
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        self.present(modalNC, animated: animated, completion: completion)
    }
    
    func deselectCell() {
        if let selectedDate {
            calendarView.getJTACalendar.deselect(dates: [selectedDate])
        }
    }
    
    func didFilterButtonTap() {
        let workplaceService = WorkplaceService()
        let workplaceRepository = WorkplaceRepository(service: workplaceService)
        let workplaceUseCase = WorkplaceUseCase(repository: workplaceRepository)
        let filterVM = FilterViewModel(workplaceUseCase: workplaceUseCase)
        let filterModalVC = FilterViewController(viewModel: filterVM,
                                                 calendarMode: calendarModeRelay.value,
                                                 prevFilterModel: filterModelRelay.value)
        filterModalVC.delegate = self
        
        if let sheet = filterModalVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        self.present(filterModalVC, animated: true)
    }
    
    func populateDataSource(calendarModelLists: (personal: [CalendarModel], shared: [CalendarModel])) {
        // TODO: 수신한 데이터 지우지 않는 방향으로 수정
        personalEventDataSource.removeAll()
        sharedEventDataSource.removeAll()
        for model in calendarModelLists.personal {
            let event = model.eventInfo.calendarEvent
            guard let eventDate = DateFormatter.dataSourceDateFormatter.date(from: event.eventDate) else { continue }
            personalEventDataSource[eventDate, default: []].append(model)
        }
        for model in calendarModelLists.shared {
            let event = model.eventInfo.calendarEvent
            guard let eventDate = DateFormatter.dataSourceDateFormatter.date(from: event.eventDate) else { continue }
            sharedEventDataSource[eventDate, default: []].append(model)
        }
        
        calendarView.getJTACalendar.reloadData()
    }
    
    func updateCalendar() {
        visibleYearMonth.accept(visibleYearMonth.value)
    }
}

// MARK: - JTACMonthViewDataSource

extension CalendarViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
        let startDate = DateFormatter.dataSourceDateFormatter.date(from: "\(CalendarRange.startYear.rawValue).01.01")
        let endDate = DateFormatter.dataSourceDateFormatter.date(from: "\(CalendarRange.endYear.rawValue).12.31")
        
        let parameter = ConfigurationParameters(startDate: startDate ?? .distantPast,
                                                endDate: endDate ?? .distantFuture,
                                                generateInDates: .forAllMonths,
                                                generateOutDates: .tillEndOfRow)
        
        return parameter
    }
}

// MARK: - JTACMonthViewDelegate

extension CalendarViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
        switch calendarModeRelay.value {
        case .personal:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarModeRelay.value, modelList: personalEventDataSource[date] ?? [])
        case .shared:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarModeRelay.value, modelList: sharedEventDataSource[date] ?? [])
        }
    }
    
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as? CalendarDayCell else { return JTACDayCell() }
        
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        calendarView.setMonthLabel(date: date)
        visibleYearMonth.accept((year: currCalendar.component(.year, from: date),
                                 month: currCalendar.component(.month, from: date)))
    }
    
    // 이미 선택된 셀인 경우 ➡️ 선택 해제
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        // CalendarEventListViewController가 present 중인지 확인
        if let navVC = self.presentedViewController as? UINavigationController,
           navVC.viewControllers.first is CalendarEventListViewController {
            // present 중이면 셀 선택 불가
            return false
        }
        
        // present 중이 아니면 셀 선택 가능
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        selectedDate = date
        
        let day = currCalendar.component(.day, from: date)
        switch calendarModeRelay.value {
        case .personal:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarModeRelay.value, modelList: personalEventDataSource[date] ?? [])
            didSelectCell(day: day, calendarModelList: personalEventDataSource[date] ?? [])
        case .shared:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarModeRelay.value, modelList: sharedEventDataSource[date] ?? [])
            didSelectCell(day: day, calendarModelList: sharedEventDataSource[date] ?? [])
        }
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        selectedDate = nil
        
        switch calendarModeRelay.value {
        case .personal:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarModeRelay.value, modelList: personalEventDataSource[date] ?? [])
        case .shared:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarModeRelay.value, modelList: sharedEventDataSource[date] ?? [])
        }
        self.navigationController?.presentedViewController?.dismiss(animated: true)
    }
}

// MARK: - CalendarEventListVCDelegate

extension CalendarViewController: CalendarEventListVCDelegate {
    func didTapEventCell(model: CalendarModel) {
        if let routineId = model.eventInfo.calendarEvent.routineIds.first {
            pendingEventSelection = (selectedDate: selectedDate ?? .now, model: model, isEdit: false)
            searchRoutineIdRelay.accept(routineId)
        } else {
            presentRegisterVC(date: selectedDate ?? .now, model: model, routineTitle: "루틴 추가", isRegister: false, isEdit: false)
        }
    }
    
    func didTapEditMenu(model: CalendarModel) {
        if let routineId = model.eventInfo.calendarEvent.routineIds.first {
            pendingEventSelection = (selectedDate: selectedDate ?? .now, model: model, isEdit: true)
            searchRoutineIdRelay.accept(routineId)
        } else {
            presentRegisterVC(date: selectedDate ?? .now, model: model, routineTitle: "루틴 추가", isRegister: false, isEdit: true)
        }
    }
    
    func didTapRegisterButton() {
        presentRegisterVC(date: selectedDate ?? .now, model: nil, routineTitle: nil, isRegister: true, isEdit: true)
    }
    
    func didDeleteEvent() {
        updateCalendar()
    }
    
    func presentationControllerDidDismiss() {
        deselectCell()
    }
}

// MARK: - OnboardingVCDelegate

extension CalendarViewController: OnboardingVCDelegate {
    func onboardingVCWillDisappear() {
        self.presentedViewController?.dismiss(animated: true)
    }
}

// MARK: - YearMonthPickerVCDelegate

extension CalendarViewController: YearMonthPickerDelegate {
    func didTapGotoButton(year: Int, month: Int) {
        let yearMonthText = "\(year). \(month)"
        guard let date = DateFormatter.yearMonthDateFormatter.date(from: yearMonthText) else { return }
        calendarView.getJTACalendar.scrollToDate(date)
    }
}

// MARK: - FilterVCDelegate

extension CalendarViewController: FilterVCDelegate {
    func didApplyButtonTap(model: FilterModel?) {
        filterModelRelay.accept(model)
    }
}

// MARK: - RegistrationVCDelegate

extension CalendarViewController: RegistrationVCDelegate {
    func registrationVCIsMovingFromParent(dateValue: String) {
        guard let registeredDate = DateFormatter.dataSourceDateFormatter.date(from: dateValue) else { return }
        calendarView.getJTACalendar.scrollToDate(registeredDate, animateScroll: true)
        calendarView.getJTACalendar.selectDates([registeredDate])
    }
}
