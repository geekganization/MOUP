//
//  BasePickerViewController.swift
//  Routory
//
//  Created by 서동환 on 7/1/25.
//

import UIKit

import RxCocoa
import RxSwift

final class BasePickerViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var yearMonthPickerdelegate: YearMonthPickerDelegate?
    
    private let disposeBag = DisposeBag()
    
    private let mode: PickerMode
    private let currYear: Int?
    private let currMonth: Int?
    
    // MARK: - UI Components
    
    private let basePickerView: BasePickerView
    
    // MARK: - Getter
    
    var getBasePickerView: BasePickerView { basePickerView }
    
    // MARK: - Initializer
    
    init(mode: PickerMode,
         focusedDateStr: String? = nil,
         currYear: Int? = nil,
         currMonth: Int? = nil,
         focusedDay: Int? = nil,
         focusedTimeStr: String? = nil,
         focusedBreakTimeStr: String? = nil) {
        self.mode = mode
        self.currYear = currYear
        self.currMonth = currMonth
        self.basePickerView = BasePickerView(mode: mode,
                                             focusedDateStr: focusedDateStr,
                                             focusedYear: currYear,
                                             focusedMonth: currMonth,
                                             focusedDay: focusedDay,
                                             focusedTimeStr: focusedTimeStr,
                                             focusedBreakTimeStr: focusedBreakTimeStr)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = basePickerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

// MARK: - UI Methods

private extension BasePickerViewController {
    func configure() {
        setStyles()
        setBindings()
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    func setBindings() {
        basePickerView.getCancelButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
        
        basePickerView.getConfirmButton.rx.tap
            .subscribe(with: self) { owner, _ in
                let (year, month) = owner.basePickerView.getSelectedYearMonth
                owner.yearMonthPickerdelegate?.didTapGotoButton(year: year ?? 2001, month: month ?? 12)
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
}
