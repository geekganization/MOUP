//
//  YearMonthPickerViewController.swift
//  Routory
//
//  Created by 서동환 on 6/12/25.
//

import UIKit

import RxCocoa
import RxSwift
import Then

final class YearMonthPickerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    weak var delegate: YearMonthPickerVCDelegate?
    
    private let currYear: Int
    private let currMonth: Int
    
    // MARK: - UI Components
    
    private lazy var yearMonthPickerView = YearMonthPickerView(focusedYear: currYear, focusedMonth: currMonth)
    
    // MARK: - Initializer
    
    init(currYear: Int, currMonth: Int) {
        self.currYear = currYear
        self.currMonth = currMonth
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = yearMonthPickerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setDefaultSelect()
    }
}

// MARK: - UI Methods

private extension YearMonthPickerViewController {
    func configure() {
        setStyles()
        setBinding()
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    func setBinding() {
        yearMonthPickerView.getCancelButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
        
        yearMonthPickerView.getGotoButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                let (year, month) = owner.yearMonthPickerView.getSelectedYearMonth
                owner.delegate?.didTapGotoButton(year: year, month: month)
                owner.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
}

// MARK: - Private Methods

private extension YearMonthPickerViewController {
    func setDefaultSelect() {
        let yearRow = currYear - CalendarRange.startYear.rawValue
        let monthRow = currMonth - 1
        yearMonthPickerView.getPickerView.selectRow(yearRow, inComponent: PickerViewComponents.year.rawValue, animated: false)
        yearMonthPickerView.getPickerView.selectRow(monthRow, inComponent: PickerViewComponents.month.rawValue, animated: false)
    }
}
