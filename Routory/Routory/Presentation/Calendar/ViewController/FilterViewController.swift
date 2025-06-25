//
//  FilterViewController.swift
//  Routory
//
//  Created by 서동환 on 6/15/25.
//

import UIKit
import OSLog

import RxCocoa
import RxSwift

final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    weak var delegate: FilterVCDelegate?
    
    private let viewModel: FilterViewModel
    
    private let disposeBag = DisposeBag()
    
    private let calendarMode: CalendarMode
    private let prevFilterModel: FilterModel?
    
    private var selectedFilterModel = FilterModel(workplaceId: "", workplaceName: "전체 보기")
    
    // MARK: UI Components
    
    private let filterView = FilterView()
    
    // MARK: - Initializer
    
    init(viewModel: FilterViewModel, calendarMode: CalendarMode, prevFilterModel: FilterModel?) {
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
        
        UserManager.shared.getUser { [weak self] result in
            switch result {
            case .success(let user):
                if user.role == UserRole.worker.rawValue {
                    self?.filterView.getHeaderLabel.text = "나의 근무지"
                } else if user.role == UserRole.owner.rawValue {
                    self?.filterView.getHeaderLabel.text = "나의 매장"
                }
            case .failure(let error):
                self?.logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func setActions() {
        filterView.getApplyButton.rx.tap
            .subscribe(with: self) { owner, _ in
                if owner.selectedFilterModel.workplaceId.isEmpty {
                    owner.delegate?.didApplyButtonTap(model: nil)
                } else {
                    owner.delegate?.didApplyButtonTap(model: owner.selectedFilterModel)
                }
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
    
    func setBinding() {
        filterView.getFilterTableView.rx.modelSelected(FilterModel.self)
            .subscribe(with: self) { owner, model in
                owner.selectedFilterModel = model
            }.disposed(by: disposeBag)
        
        let input = FilterViewModel.Input(calendarMode: Observable.just((calendarMode)))
        
        let output = viewModel.tranform(input: input)
        
        output.filterModelListRelay
            .asDriver(onErrorJustReturn: [])
            .do(afterNext: { [weak self] list in
                self?.filterView.getFilterTableView.isHidden = list.isEmpty
            })
            .drive(filterView.getFilterTableView.rx.items(
                cellIdentifier: FilterCell.identifier, cellType: FilterCell.self)) { [weak self] index, model, cell in
                    cell.update(workplace: model.workplaceName)
                    
                    if self?.prevFilterModel == nil {
                        self?.filterView.getFilterTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .middle)
                    } else if model.workplaceId == self?.prevFilterModel?.workplaceId {
                        self?.filterView.getFilterTableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .middle)
                    }
                }.disposed(by: disposeBag)
    }
}
