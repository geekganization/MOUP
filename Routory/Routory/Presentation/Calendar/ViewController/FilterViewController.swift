//
//  FilterViewController.swift
//  Routory
//
//  Created by 서동환 on 6/15/25.
//

import UIKit

import RxCocoa
import RxSwift

final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: FilterVCDelegate?
    
    private let viewModel: FilterViewModel
    
    private let disposeBag = DisposeBag()
    
    private let calendarMode: CalendarMode
    private var selectedIndexPath = IndexPath()
    
    // MARK: UI Components
    
    private let filterView = FilterView()
    
    // MARK: - Initializer
    
    init(viewModel: FilterViewModel, calendarMode: CalendarMode) {
        self.viewModel = viewModel
        self.calendarMode = calendarMode
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = filterView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterView.getWorkplaceTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
    }
}

// MARK: - UI Methods

private extension FilterViewController {
    func configure() {
        setStyles()
        setActions()
        setBinding()
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    func setActions() {
        filterView.getApplyButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.delegate?.didApplyButtonTap()
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
    
    func setBinding() {
        filterView.getWorkplaceTableView.rx.itemSelected
            .subscribe(with: self) { owner, indexPath in
                owner.selectedIndexPath = indexPath
            }.disposed(by: disposeBag)
        
        let input = FilterViewModel.Input(calendarMode: Observable.just((calendarMode)))
        
        let output = viewModel.tranform(input: input)
        
        output.workplaceInfoListRelay
            .asDriver()
            .drive(filterView.getWorkplaceTableView.rx.items(
                cellIdentifier: WorkplaceCell.identifier, cellType: WorkplaceCell.self)) { _, model, cell in
                    cell.update(workplace: model.workplace.workplacesName)
                }.disposed(by: disposeBag)
    }
}
