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
    
    // MARK: - UI Components
    
    private let yearMonthPickerView = YearMonthPickerView()
    
    // MARK: - Initializer
    
    init(currYear: Int, currMonth: Int) {
        super.init(nibName: nil, bundle: nil)
        
        let yearRow = currYear - CalendarRange.startYear.rawValue
        let monthRow = currMonth - 1
        yearMonthPickerView.getPickerView.selectRow(yearRow, inComponent: PickerViewComponents.year.rawValue, animated: false)
        yearMonthPickerView.getPickerView.selectRow(monthRow, inComponent: PickerViewComponents.month.rawValue, animated: false)
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
                owner.delegate?.gotoButtonDidTapped(year: year, month: month)
                owner.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
}
