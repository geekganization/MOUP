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
import Then

final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let viewModel: CalendarViewModel
    
    private let disposeBag = DisposeBag()
    
    private let calendarMode = BehaviorRelay<CalendarMode>(value: .personal)
    
    private let filterWorkplace = BehaviorRelay<String>(value: "전체 보기")
    
    /// `calendarView`에서 `dataSource` 관련 데이터의 연/월 형식을 만들기 위한 `DateFormatter`
    private let dataSourceDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy.MM.dd"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    private var personalEventDataSource: [Date: [CalendarEvent]] = [:]
    private var sharedEventDataSource: [Date: [CalendarEvent]] = [:]
    
    private let visibleYearMonth = BehaviorRelay<(year: Int, month: Int)>(value: (year: Calendar.current.component(.year, from: .now), month: Calendar.current.component(.month, from: .now)))
    private var selectedDate: Date?
    
    // MARK: - UI Components
    
    private let calendarView = CalendarView()
    
    // MARK: - Initializer
    
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
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
        let yearMonthLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didYearMonthLabelTap(_:)))
        calendarView.getCalendarHeaderView.getYearMonthLabel.addGestureRecognizer(yearMonthLabelTapRecognizer)
        
        // 개인/공유 캘린더 토글 스위치
        calendarView.getCalendarHeaderView.getToggleSwitch.addAction(UIAction(handler: { [weak self] action in
            self?.deselectCell()
            
            guard let sender = action.sender as? BetterSegmentedControl else { return }
            self?.calendarMode.accept(CalendarMode.allCases[sender.index])
        }), for: .valueChanged)
    }
    
    func setBinding() {
        calendarMode
            .subscribe(with: self) { owner, mode in
                owner.calendarView.getJTACalendar.reloadData()
            }.disposed(by: disposeBag)
        
        // 근무지/매장 필터 버튼
        calendarView.getCalendarHeaderView.getFilterButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.didFilterButtonTap()
            }.disposed(by: disposeBag)
        
        let input = CalendarViewModel.Input(loadMonthEvent: visibleYearMonth.asObservable(),
                                            filterWorkplace: filterWorkplace.asObservable())
        
        let output = viewModel.tranform(input: input)
        
        output.calendarEventListRelay
            .asDriver(onErrorJustReturn: ([], []))
            .drive(with: self) { owner, calendarEventList in
                owner.populateDataSource(calendarEvents: calendarEventList)
            }.disposed(by: disposeBag)
    }
}

// MARK: - @objc Methods

@objc private extension CalendarViewController {
    func didCalendarViewTap(_ sender: UITapGestureRecognizer) {
        deselectCell()
    }
    
    func didYearMonthLabelTap(_ sender: UITapGestureRecognizer) {
        deselectCell()
        
        guard let yearMonthText = calendarView.getCalendarHeaderView.getYearMonthLabel.text,
              let currYear = Int(yearMonthText.prefix(4)),
              let currMonth = Int(yearMonthText.suffix(2)) else { return }
        
        let pickerModalVC = YearMonthPickerViewController(currYear: currYear, currMonth: currMonth)
        pickerModalVC.delegate = self
        
        if let sheet = pickerModalVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
        
        self.present(pickerModalVC, animated: true)
    }
}

// MARK: - CalendarView Methods

private extension CalendarViewController {
    /// `jtaCalendar`의 셀을 탭했을 때 호출하는 메서드
    ///
    /// - Parameters:
    ///   - day: 탭한 셀의 일
    ///   - eventList: 탭한 셀의 일에 해당하는 `CalendarEvent` 배열
    func didSelectCell(day: Int, eventList: [CalendarEvent]) {
        let calendarEventListVM = CalendarEventListViewModel(eventList: eventList)
        let calendarEventListVC = CalendarEventListViewController(viewModel: calendarEventListVM, day: day, calendarMode: calendarMode.value)
        calendarEventListVC.delegate = self
        
        let modalNC = UINavigationController(rootViewController: calendarEventListVC)
        
        if let sheet = modalNC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 0
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        self.present(modalNC, animated: true)
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
        let filterModalVC = FilterViewController(viewModel: filterVM, calendarMode: calendarMode.value)
        filterModalVC.delegate = self
        
        if let sheet = filterModalVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        self.present(filterModalVC, animated: true)
    }
    
    func populateDataSource(calendarEvents: (personal: [CalendarEvent], shared: [CalendarEvent])) {
        // TODO: 수신한 데이터 지우지 않는 방향으로 수정
        personalEventDataSource.removeAll()
        sharedEventDataSource.removeAll()
        for event in calendarEvents.personal {
            guard let eventDate = dataSourceDateFormatter.date(from: event.eventDate) else { continue }
            personalEventDataSource[eventDate, default: []].append(event)
        }
        for event in calendarEvents.shared {
            guard let eventDate = dataSourceDateFormatter.date(from: event.eventDate) else { continue }
            sharedEventDataSource[eventDate, default: []].append(event)
        }
        
        calendarView.getJTACalendar.reloadData()
    }
}

// MARK: - JTACMonthViewDataSource

extension CalendarViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
        let startDate = dataSourceDateFormatter.date(from: "\(CalendarRange.startYear.rawValue).01.01")
        let endDate = dataSourceDateFormatter.date(from: "\(CalendarRange.endYear.rawValue).12.31")
        
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
        switch calendarMode.value {
        case .personal:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarMode.value, calendarEventList: personalEventDataSource[date] ?? [])
        case .shared:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarMode.value, calendarEventList: sharedEventDataSource[date] ?? [])
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
        visibleYearMonth.accept((year: Calendar.current.component(.year, from: date),
                                 month: Calendar.current.component(.month, from: date)))
    }
    
    // 이미 선택된 셀인 경우 ➡️ 선택 해제
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        if self.presentedViewController != nil {
            return false
        }
        
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        selectedDate = date
        
        let day = Calendar.current.component(.day, from: date)
        switch calendarMode.value {
        case .personal:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarMode.value, calendarEventList: personalEventDataSource[date] ?? [])
            didSelectCell(day: day, eventList: personalEventDataSource[date] ?? [])
        case .shared:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarMode.value, calendarEventList: sharedEventDataSource[date] ?? [])
            didSelectCell(day: day, eventList: sharedEventDataSource[date] ?? [])
        }
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        selectedDate = nil
        
        switch calendarMode.value {
        case .personal:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarMode.value, calendarEventList: personalEventDataSource[date] ?? [])
        case .shared:
            calendarView.configureCell(cell: cell, date: date, cellState: cellState, calendarMode: calendarMode.value, calendarEventList: sharedEventDataSource[date] ?? [])
        }
        self.dismiss(animated: true)
    }
}

// MARK: - CalendarEventListVCDelegate

extension CalendarViewController: CalendarEventListVCDelegate {
    func presentationControllerDidDismiss() {
        deselectCell()
    }
    
    func didTapEventCell() {
        // TODO: 존재하는 근무 표시
        UserManager.shared.getUser { [weak self] result in
            switch result {
            case .success(let user):
                if user.role == UserRole.worker.rawValue {
                    let workShiftRegisterVC = WorkShiftRegistrationViewController()
                    workShiftRegisterVC.hidesBottomBarWhenPushed = true
                    workShiftRegisterVC.delegate = self
                    
                    self?.navigationController?.pushViewController(workShiftRegisterVC, animated: true)
                    self?.tabBarController?.presentedViewController?.dismiss(animated: true)
                } else if user.role == UserRole.owner.rawValue {
                    let ownerShiftRegisterVC = OwnerShiftRegistrationViewController()
                    ownerShiftRegisterVC.hidesBottomBarWhenPushed = true
                    ownerShiftRegisterVC.delegate = self
                    
                    self?.navigationController?.pushViewController(ownerShiftRegisterVC, animated: true)
                    self?.tabBarController?.presentedViewController?.dismiss(animated: true)
                }
            case .failure(let error):
                self?.logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func didTapAssignButton() {
        UserManager.shared.getUser { [weak self] result in
            switch result {
            case .success(let user):
                if user.role == UserRole.worker.rawValue {
                    let workShiftRegisterVC = WorkShiftRegistrationViewController()
                    workShiftRegisterVC.hidesBottomBarWhenPushed = true
                    workShiftRegisterVC.delegate = self
                    
                    self?.navigationController?.pushViewController(workShiftRegisterVC, animated: true)
                    self?.tabBarController?.presentedViewController?.dismiss(animated: true)
                } else if user.role == UserRole.owner.rawValue {
                    let ownerShiftRegisterVC = OwnerShiftRegistrationViewController()
                    ownerShiftRegisterVC.hidesBottomBarWhenPushed = true
                    ownerShiftRegisterVC.delegate = self
                    
                    self?.navigationController?.pushViewController(ownerShiftRegisterVC, animated: true)
                    self?.tabBarController?.presentedViewController?.dismiss(animated: true)
                }
            case .failure(let error):
                self?.logger.error("\(error.localizedDescription)")
            }
        }
    }
}

// MARK: - YearMonthPickerVCDelegate

extension CalendarViewController: YearMonthPickerVCDelegate {
    func didTapGotoButton(year: Int, month: Int) {
        let yearMonthText = "\(year). \(month)"
        guard let date = calendarView.getDateFormatter.date(from: yearMonthText) else { return }
        calendarView.getJTACalendar.scrollToDate(date)
    }
}

// MARK: -

extension CalendarViewController: FilterVCDelegate {
    func didApplyButtonTap(workplaceText: String) {
        filterWorkplace.accept(workplaceText)
    }
}

// MARK: - RegistrationVCDelegate

extension CalendarViewController: RegistrationVCDelegate {
    func registrationVCIsMovingFromParent() {
        // TODO: 해당 날짜 이벤트 다시 로드
        guard let selectedDate else { return }
        calendarView.getJTACalendar.selectDates([selectedDate])
        // TODO: 근무 추가 후 캘린더 업데이트 해야함
        calendarView.getJTACalendar.reloadData()
    }
}
