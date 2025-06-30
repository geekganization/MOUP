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
    
    /// `UIPickerViewDataSource`에 사용될 연/월 2차원 배열
    private let yearMonthList: [[Int]]
    
    /// `pickerView`에서 didSelect된 연도
    private var focusedYear: Int?
    /// `pickerView`에서 didSelect된 월
    private var focusedMonth: Int?
    /// `pickerView`에서 didSelect된 월
    private var focusedDay: Int?
    
    // MARK: - UI Components
    
    /// 모달 핸들을 표시하는 `GrabberView`
    private let grabberView = GrabberView()
    
    private var yearMonthDayPickerView: UIDatePicker?
    private var yearMonthPickerView: UIPickerView?
    private var dayPickerView: UIPickerView?
    
    /// 취소 `BaseButton`
    private let cancelButton = BaseButton(title: "취소", isSecondary: true)
    
    /// 확인 `UIButton`
    private let confirmButton = BaseButton(title: "확인")
    
    /// `UIButton`을 담는 수평 `UIStackView`
    private let buttonHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }

    // MARK: - Getter
    
    var getYearMonthDayPickerView: UIDatePicker? { yearMonthDayPickerView }
    var getYearMonthPickerView: UIPickerView? { yearMonthPickerView }
    var getDayPickerView: UIPickerView? { dayPickerView }
    var getCancelButton: BaseButton { cancelButton }
    var getConfirmButton: BaseButton { confirmButton }
    
    // MARK: - Initializer
    
    init(mode: PickerMode, focusedYear: Int?, focusedMonth: Int?, focusedDay: Int?) {
        yearMonthList = [Array(CalendarRange.startYear.rawValue...CalendarRange.endYear.rawValue), Array(1...12)]
        self.focusedYear = focusedYear
        self.focusedMonth = focusedMonth
        super.init(frame: .zero)
        
        configure()
        switch mode {
        case .yearMonthDay:
            makeDatePickerView()
        case .yearMonth:
            guard let focusedYear, let focusedMonth else { return }
            makeYearMonthPickerView(focusedYear: focusedYear, focusedMonth: focusedMonth)
        case .day:
            makeDayPickerView()
        case .time:
            break
        case .minute:
            break
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
    func makeDatePickerView() {
        /// 연/월/일을 선택하는 `UIDatePicker`
        yearMonthDayPickerView = UIDatePicker().then {
            $0.backgroundColor = .white
            $0.locale = Locale(identifier: "ko-KR")
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .wheels
            $0.minimumDate = CalendarRange.startYear.referenceDate
            $0.maximumDate = CalendarRange.endYear.referenceDate
        }
        guard let yearMonthDayPickerView else { return }
        self.addSubview(yearMonthDayPickerView)
        yearMonthDayPickerView.snp.makeConstraints {
            $0.top.equalTo(grabberView).offset(16)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(confirmButton.snp.top).offset(-12)
        }
    }
    
    func makeYearMonthPickerView(focusedYear: Int, focusedMonth: Int) {
        yearMonthPickerView = UIPickerView().then {
            $0.backgroundColor = .white
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
    }
    
    func makeDayPickerView() {
        dayPickerView = UIPickerView().then {
            $0.backgroundColor = .white
            $0.dataSource = self
            $0.delegate = self
        }
    }
}

// MARK: - UIPickerViewDataSource

extension BasePickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return yearMonthList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearMonthList[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(yearMonthList[component][row])
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
        label.text = String(yearMonthList[component][row])
        label.font = .headBold(20)
        label.textColor = .gray900
        label.textAlignment = .center
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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


