//
//  BasePickerView.swift
//  Routory
//
//  Created by 서동환 on 7/1/25.
//

import UIKit

import SnapKit
import Then

final class BasePickerView: UIView {
    
    // MARK: - Properties
    
    private let mode: PickerMode
    
    private var currCalendar = Calendar.current
    
    /// `yearMonthPickerView`의 `UIPickerViewDataSource`에 사용될 연/월 2차원 배열
    private var yearMonthList: [[Int]]?
    /// `paydayPickerView`의 `UIPickerViewDataSource`에 사용될 급여일 배열
    private var paydayList: [String]?
    /// `breakTimePickerView`의 `UIPickerViewDataSource`에 사용될 휴게시간 배열
    private var breakTimeList: [String]?
    
    /// `yearMonthPickerView`에서 `didSelect`된 연도
    private var focusedYear: Int?
    /// `yearMonthPickerView`에서 `didSelect`된 월
    private var focusedMonth: Int?
    /// `paydayPickerView`에서 `didSelect`된 일
    private var focusedPayday: Int?
    
    // MARK: - UI Components
    
    /// 모달 핸들을 표시하는 `GrabberView`
    private let grabberView = GrabberView()
    
    private var yearMonthDayPickerView: UIDatePicker?
    private var yearMonthPickerView: UIPickerView?
    private var paydayPickerView: UIPickerView?
    private var timePickerView: UIDatePicker?
    private var breakTimePickerView: UIPickerView?
    
    /// 취소 `BaseButton`
    private lazy var cancelButton = BaseButton(title: "취소", isSecondary: true)
    
    /// 이동 or 확인 `UIButton`
    private lazy var confirmButton = BaseButton(title: mode == .yearMonth ? "이동" : "확인")
    
    /// `UIButton`을 담는 수평 `UIStackView`
    private let buttonHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    // MARK: - Getter
    
    var getSelectedYearMonth: (year: Int?, month: Int?) { (focusedYear, focusedMonth) }
    
    var getYearMonthDayPickerView: UIDatePicker? { yearMonthDayPickerView }
    var getYearMonthPickerView: UIPickerView? { yearMonthPickerView }
    var getPaydayPickerView: UIPickerView? { paydayPickerView }
    var getTimePickerView: UIDatePicker? { timePickerView }
    var getBreakTimePickerView: UIPickerView? { breakTimePickerView }
    var getCancelButton: BaseButton { cancelButton }
    var getConfirmButton: BaseButton { confirmButton }
    
    // MARK: - Initializer
    
    init(mode: PickerMode,
         focusedDateStr: String?,
         focusedYear: Int?,
         focusedMonth: Int?,
         focusedPayday: Int?,
         focusedTimeStr: String?,
         focusedBreakTimeStr: String?) {
        self.mode = mode
        self.currCalendar.timeZone = .autoupdatingCurrent
        self.focusedYear = focusedYear
        self.focusedMonth = focusedMonth
        self.focusedPayday = focusedPayday
        super.init(frame: .zero)
        
        configure()
        switch mode {
        case .yearMonthDay:
            makeYearMonthDayPickerView(focusedDateStr: focusedDateStr)
        case .yearMonth:
            yearMonthList = [Array(CalendarRange.startYear.rawValue...CalendarRange.endYear.rawValue), Array(1...12)]
            makeYearMonthPickerView(focusedYear: focusedYear, focusedMonth: focusedMonth)
        case .payday:
            paydayList = (1...31).map { "\($0)일" }
            makePaydayPickerView(focusedPayday: focusedPayday)
        case .time:
            makeTimePickerView(focusedTimeStr: focusedTimeStr)
        case .breakTime:
            breakTimeList = ["없음"] + (1...8).map {
                let totalMinutes = $0 * 15
                let hours = totalMinutes / 60
                let minutes = totalMinutes - hours * 60
                
                if hours > 0 && minutes > 0 {
                    return "\(hours)시간 \(minutes)분"
                } else if hours > 0 && minutes == 0 {
                    return "\(hours)시간"
                } else {
                    return "\(minutes)분"
                }
            }
            makeBreakTimePickerView(focusedBreakTimeStr: focusedBreakTimeStr)
        }
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

// MARK: - UI Methods

private extension BasePickerView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.addSubviews(grabberView,
                         buttonHStackView)
        
        buttonHStackView.addArrangedSubviews(cancelButton, confirmButton)
    }
    
    func setStyles() {
        self.backgroundColor = .primaryBackground
    }
    
    func setConstraints() {
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalTo(self.safeAreaLayoutGuide)
            $0.width.equalTo(45)
            $0.height.equalTo(4)
        }
        
        buttonHStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
    }
}

// MARK: - Picker Making Methods

private extension BasePickerView {
    func makeYearMonthDayPickerView(focusedDateStr: String?) {
        let date = DateFormatter.dataSourceDateFormatter.date(from: focusedDateStr ?? "2001.01.01")
        /// 연/월/일을 선택하는 `UIDatePicker`
        yearMonthDayPickerView = UIDatePicker().then {
            $0.backgroundColor = .primaryBackground
            $0.locale = Locale(identifier: "ko-KR")
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .wheels
            $0.minimumDate = CalendarRange.startYear.referenceDate
            $0.maximumDate = CalendarRange.endYear.referenceDate
            
            $0.setDate(date ?? .now, animated: false)
        }
        guard let yearMonthDayPickerView else { return }
        self.addSubview(yearMonthDayPickerView)
        yearMonthDayPickerView.snp.makeConstraints {
            $0.top.equalTo(grabberView).offset(16)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(confirmButton.snp.top).offset(-12)
        }
    }
    
    func makeYearMonthPickerView(focusedYear: Int?, focusedMonth: Int?) {
        yearMonthPickerView = UIPickerView().then {
            $0.backgroundColor = .primaryBackground
            $0.dataSource = self
            $0.delegate = self
        }
        guard let yearMonthPickerView else { return }
        self.addSubview(yearMonthPickerView)
        yearMonthPickerView.snp.makeConstraints {
            $0.top.equalTo(grabberView).offset(16)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(confirmButton.snp.top).offset(-12)
        }
        
        let yearRow = (focusedYear ?? 2001) - CalendarRange.startYear.rawValue
        let monthRow = (focusedMonth ?? 1) - 1
        yearMonthPickerView.selectRow(yearRow, inComponent: YearMonthPickerViewComponents.year.rawValue, animated: false)
        yearMonthPickerView.selectRow(monthRow, inComponent: YearMonthPickerViewComponents.month.rawValue, animated: false)
    }
    
    func makePaydayPickerView(focusedPayday: Int?) {
        paydayPickerView = UIPickerView().then {
            $0.backgroundColor = .primaryBackground
            $0.dataSource = self
            $0.delegate = self
        }
        guard let paydayPickerView else { return }
        self.addSubview(paydayPickerView)
        paydayPickerView.snp.makeConstraints {
            $0.top.equalTo(grabberView).offset(16)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(confirmButton.snp.top).offset(-12)
        }
        let row = (focusedPayday ?? 15) - 1
        paydayPickerView.selectRow(row, inComponent: 0, animated: false)
    }
    
    func makeTimePickerView(focusedTimeStr: String?) {
        let parts = focusedTimeStr?.split(separator: ":").compactMap({ Int($0) })
        if parts?.count != 2 { return }
        
        var components = currCalendar.dateComponents([.year, .month, .day], from: .now)
        components.hour = parts?[0]
        components.minute = parts?[1]
        let date = Calendar.current.date(from: components)
        /// 시간을 선택하는 `UIDatePicker`
        timePickerView = UIDatePicker().then {
            $0.backgroundColor = .primaryBackground
            $0.locale = Locale(identifier: "en-GB")  // 24시간제
            $0.datePickerMode = .time
            $0.preferredDatePickerStyle = .wheels
            
            $0.setDate(date ?? .now, animated: false)
        }
        guard let timePickerView else { return }
        self.addSubview(timePickerView)
        timePickerView.snp.makeConstraints {
            $0.top.equalTo(grabberView).offset(16)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(confirmButton.snp.top).offset(-12)
        }
    }
    
    func makeBreakTimePickerView(focusedBreakTimeStr: String?) {
        breakTimePickerView = UIPickerView().then {
            $0.backgroundColor = .primaryBackground
            $0.dataSource = self
            $0.delegate = self
        }
        guard let breakTimePickerView else { return }
        self.addSubview(breakTimePickerView)
        breakTimePickerView.snp.makeConstraints {
            $0.top.equalTo(grabberView).offset(16)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(confirmButton.snp.top).offset(-12)
        }
        guard let row = breakTimeList?.firstIndex(of: focusedBreakTimeStr ?? "없음") else { return }
        breakTimePickerView.selectRow(row, inComponent: 0, animated: false)
    }
}

// MARK: - UIPickerViewDataSource

extension BasePickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch mode {
        case .yearMonthDay:
            return 0
        case .yearMonth:
            return yearMonthList?.count ?? 2
        case .payday:
            return 1
        case .time:
            return 0
        case .breakTime:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch mode {
        case .yearMonthDay:
            return 0
        case .yearMonth:
            return yearMonthList?[component].count ?? 0
        case .payday:
            return paydayList?.count ?? 0
        case .time:
            return 0
        case .breakTime:
            return breakTimeList?.count ?? 0
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch mode {
        case .yearMonthDay:
            return nil
        case .yearMonth:
            return String(yearMonthList?[component][row] ?? 0)
        case .payday:
            return paydayList?[row] ?? ""
        case .time:
            return nil
        case .breakTime:
            return breakTimeList?[row] ?? ""
        }
        
    }
}

// MARK: - UIPickerViewDelegate

extension BasePickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        let text: String?
        switch mode {
        case .yearMonthDay:
            text = nil
        case .yearMonth:
            text = String(yearMonthList?[component][row] ?? 0)
        case .payday:
            text = String(paydayList?[row] ?? "")
        case .time:
            text = nil
        case .breakTime:
            text = String(breakTimeList?[row] ?? "")
        }
        label.text = text
        label.font = .headBold(20)
        label.textColor = .gray900
        label.textAlignment = .center
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if mode == .yearMonth {
            switch component {
            case YearMonthPickerViewComponents.year.rawValue:
                focusedYear = row + CalendarRange.startYear.rawValue
            case YearMonthPickerViewComponents.month.rawValue:
                focusedMonth = row + 1
            default:
                break
            }
        }
    }
}


