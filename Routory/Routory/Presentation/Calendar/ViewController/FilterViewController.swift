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
    private let prevFilterModel: FilterModel
    private var prevFilterIndex: Int?
    
    private var selectedFilterModel = FilterModel(workplaceId: "", workplaceName: "전체 보기")
    
    // MARK: UI Components
    
    private let filterView = FilterView()
    
    // MARK: - Initializer
    
    init(viewModel: FilterViewModel, calendarMode: CalendarMode, prevFilterModel: FilterModel) {
        self.viewModel = viewModel
        self.calendarMode = calendarMode
        self.prevFilterModel = prevFilterModel
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
                owner.delegate?.didApplyButtonTap(model: owner.selectedFilterModel)
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
    
    func setBinding() {
        filterView.getWorkplaceTableView.rx.modelSelected(FilterModel.self)
            .subscribe(with: self) { owner, model in
                owner.selectedFilterModel = model
            }.disposed(by: disposeBag)
        
        let input = FilterViewModel.Input(calendarMode: Observable.just((calendarMode)))
        
        let output = viewModel.tranform(input: input)
        
        output.filterModelListRelay
            .asDriver(onErrorJustReturn: [])
            .do(afterNext: { [weak self] list in
                self?.filterView.getWorkplaceTableView.isHidden = list.isEmpty
            })
            .drive(filterView.getWorkplaceTableView.rx.items(
                cellIdentifier: WorkplaceCell.identifier, cellType: WorkplaceCell.self)) { [weak self] index, model, cell in
                    cell.update(workplace: model.workplaceName)
                    
                    if model.workplaceId == self?.prevFilterModel.workplaceId {
                        self?.filterView.getWorkplaceTableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .middle)
                    }
                }.disposed(by: disposeBag)
    }
}
