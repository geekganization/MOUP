//
//  CalendarHeaderView.swift
//  Routory
//
//  Created by 서동환 on 6/10/25.
//

import UIKit

import BetterSegmentedControl
import RxCocoa
import RxSwift
import SnapKit
import Then

final class CalendarHeaderView: UIView {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    /// `UIPickerViewDataSource`에 사용될 연/월 2차원 배열
    private let yearMonthList: [[Int]]
    
    /// `pickerView`에서 didSelect된 연도
    private var focusedYear = JTACalendarRange.startYear.rawValue
    /// `pickerView`에서 didSelect된 월
    private var focusedMonth = 1
    
    /// `pickerView`에서 확정된(이동 버튼이 눌린 뒤) row, component 배열
    private var selectedRowComponent = PublishRelay<[Int]>()
    
    // MARK: - UI Components
    
    /// 연.월 표시 및 `UIPickerView` 사용을 위한 `UITextField`
    private let yearMonthTextField = UITextField().then {
        $0.text = "2001. 01"
        $0.textColor = .gray900
        $0.font = .headBold(20)
        $0.tintColor = .clear
    }
    
    /// 토글 스위치 `BetterSegmentedControl` 라이브러리
    private let toggleSwitch = BetterSegmentedControl().then {
        $0.segments = LabelSegment.segments(withTitles: ["개인", "공유"],
                                            normalFont: .buttonSemibold(16),
                                            normalTextColor: .gray400,
                                            selectedFont: .buttonSemibold(16),
                                            selectedTextColor: .white)
        $0.setOptions([.cornerRadius(12.5),
                       .indicatorViewBackgroundColor(.gray700),
                       .backgroundColor(.gray100)])
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.borderWidth = 1
    }
    
    /// 필터 `UIButton`
    private let filterButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "slider.horizontal.3")?.withTintColor(.gray900, renderingMode: .alwaysOriginal)
        config.contentInsets = .init(top: 12, leading: 10, bottom: 12, trailing: 10)
        
        $0.configuration = config
    }
    
    /// 이동할 연/월을 선택하는 `UIPickerView`
    private lazy var pickerView = UIPickerView().then {
        $0.backgroundColor = .white
        
        let pickerToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 375, height: 30)).then {
            $0.barStyle = .default
            $0.sizeToFit()
            
            let cancelItem = UIBarButtonItem(title: "취소", primaryAction: UIAction(handler: { [weak self] _ in
                guard let self else { return }
                self.yearMonthTextField.resignFirstResponder()
            }))
            cancelItem.setTitleTextAttributes([.font: UIFont.bodyMedium(16), .foregroundColor: UIColor.gray900], for: .normal)
            cancelItem.setTitleTextAttributes([.font: UIFont.bodyMedium(16), .foregroundColor: UIColor.gray900], for: .selected)
            let space = UIBarButtonItem(systemItem: .flexibleSpace)
            let gotoItem = UIBarButtonItem(title: "이동", primaryAction: UIAction(handler: { [weak self] _ in
                guard let self else { return }
                self.selectedRowComponent.accept([focusedYear, focusedMonth])
                self.yearMonthTextField.resignFirstResponder()
            }))
            gotoItem.setTitleTextAttributes([.font: UIFont.buttonSemibold(16), .foregroundColor: UIColor.gray900], for: .normal)
            gotoItem.setTitleTextAttributes([.font: UIFont.buttonSemibold(16), .foregroundColor: UIColor.gray900], for: .selected)
            
            $0.setItems([cancelItem, space, gotoItem], animated: false)
        }
        
        yearMonthTextField.inputView = $0
        yearMonthTextField.inputAccessoryView = pickerToolBar
    }
    
    // MARK: - Getter
    
    var getSelectedRowComponent: PublishRelay<[Int]> {
        return selectedRowComponent
    }
    
    var getYearMonthTextField: UITextField {
        return yearMonthTextField
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        yearMonthList = [Array(JTACalendarRange.startYear.rawValue...JTACalendarRange.endYear.rawValue), Array(1...12)]
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

// MARK: - UI Methods

private extension CalendarHeaderView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setDelegates()
        setBinding()
    }
    
    func setHierarchy() {
        self.addSubviews(yearMonthTextField, toggleSwitch, filterButton)
    }
    
    func setStyles() {
        toggleSwitch.segments = LabelSegment.segments(withTitles: ["개인", "공유"],
                                                      normalFont: .buttonSemibold(16),
                                                      normalTextColor: .gray400,
                                                      selectedFont: .buttonSemibold(16),
                                                      selectedTextColor: .white)
        toggleSwitch.setOptions([.cornerRadius(12.5),
                                 .indicatorViewBackgroundColor(.gray700),
                                 .backgroundColor(.gray100)])
        toggleSwitch.layer.borderColor = UIColor.gray400.cgColor
        toggleSwitch.layer.borderWidth = 1
    }
    
    func setConstraints() {
        yearMonthTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        toggleSwitch.snp.makeConstraints {
            $0.trailing.equalTo(filterButton.snp.leading).offset(-2)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(90)
            $0.height.equalTo(25)
        }
        
        filterButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(5)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
    }
    
    func setDelegates() {
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    func setBinding() {
        yearMonthTextField.rx.text.orEmpty
            .subscribe(with: self) { owner, text in
                if let currYear = Int(text.prefix(4)),
                   let currMonth = Int(text.suffix(2)) {
                    let yearRow = currYear - JTACalendarRange.startYear.rawValue
                    let monthRow = currMonth - 1
                    owner.focusedYear = currYear
                    owner.focusedMonth = currMonth
                    owner.pickerView.selectRow(yearRow, inComponent: PickerViewComponents.year.rawValue, animated: false)
                    owner.pickerView.selectRow(monthRow, inComponent: PickerViewComponents.month.rawValue, animated: false)
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - UIPickerViewDataSource

extension CalendarHeaderView: UIPickerViewDataSource {
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

extension CalendarHeaderView: UIPickerViewDelegate {
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
            focusedYear = row + JTACalendarRange.startYear.rawValue
        case PickerViewComponents.month.rawValue:
            focusedMonth = row + 1
        default:
            break
        }
    }
}
