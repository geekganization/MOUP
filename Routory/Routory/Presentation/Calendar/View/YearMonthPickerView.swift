//
//  YearMonthPickerView.swift
//  Routory
//
//  Created by 서동환 on 6/12/25.
//

import UIKit

import SnapKit
import Then

final class YearMonthPickerView: UIView {
    
    // MARK: - Properties
    
    /// `UIPickerViewDataSource`에 사용될 연/월 2차원 배열
    private let yearMonthList: [[Int]]
    
    /// `pickerView`에서 didSelect된 연도
    private var focusedYear = CalendarRange.startYear.rawValue
    /// `pickerView`에서 didSelect된 월
    private var focusedMonth = 1
    
    // MARK: - UI Components
    
    /// 이동할 연/월을 선택하는 `UIPickerView`
    private lazy var pickerView = UIPickerView().then {
        $0.backgroundColor = .white
    }
    
    /// 연/월 선택 이동 취소 `UIButton`
    private let cancelButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = .init("취소", attributes: .init([.font: UIFont.buttonSemibold(18), .foregroundColor: UIColor.gray600]))
        config.baseBackgroundColor = .gray200
        $0.configuration = config
        
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    /// 연/월 선택 이동 `UIButton`
    private let gotoButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = .init("이동", attributes: .init([.font: UIFont.buttonSemibold(18), .foregroundColor: UIColor.white]))
        $0.configuration = config
        
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    /// `UIButton`을 담는 수평 `UIStackView`
    private let buttonHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    // MARK: - Getter
    
    var getSelectedYearMonth: (year: Int, month: Int) { (focusedYear, focusedMonth) }
    var getCancelButton: UIButton { cancelButton }
    var getGotoButton: UIButton { gotoButton }
    var getPickerView: UIPickerView { pickerView }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        yearMonthList = [Array(CalendarRange.startYear.rawValue...CalendarRange.endYear.rawValue), Array(1...12)]
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

private extension YearMonthPickerView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setDelegates()
    }
    
    func setHierarchy() {
        self.addSubviews(pickerView,
                         buttonHStackView)
        
        buttonHStackView.addArrangedSubviews(cancelButton, gotoButton)
    }
    
    func setStyles() {
        self.backgroundColor = .primaryBackground
    }
    
    func setConstraints() {
        pickerView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(buttonHStackView.snp.top).offset(-12)
        }
        
        buttonHStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
    }
    
    func setDelegates() {
        pickerView.dataSource = self
        pickerView.delegate = self
    }
}

// MARK: - UIPickerViewDataSource

extension YearMonthPickerView: UIPickerViewDataSource {
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

extension YearMonthPickerView: UIPickerViewDelegate {
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
        case PickerViewComponents.year.rawValue:
            focusedYear = row + CalendarRange.startYear.rawValue
        case PickerViewComponents.month.rawValue:
            focusedMonth = row + 1
        default:
            break
        }
    }
}

