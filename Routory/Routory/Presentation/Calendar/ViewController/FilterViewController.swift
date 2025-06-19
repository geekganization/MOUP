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
    private let prevFilterWorkplace: String
    private var prevFilterIndex: Int?
    
    // MARK: UI Components
    
    private let filterView = FilterView()
    
    // MARK: - Initializer
    
    init(viewModel: FilterViewModel, calendarMode: CalendarMode, prevFilterWorkplace: String) {
        self.viewModel = viewModel
        self.calendarMode = calendarMode
        self.prevFilterWorkplace = prevFilterWorkplace
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
                guard let selectedIndexPath = owner.filterView.getWorkplaceTableView.indexPathForSelectedRow,
                      let selectedCell = owner.filterView.getWorkplaceTableView.cellForRow(at: selectedIndexPath) as? WorkplaceCell else { return }
                
                owner.delegate?.didApplyButtonTap(workplaceText: selectedCell.getWorkplaceLabel.text ?? "전체 보기")
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
    
    func setBinding() {
        let input = FilterViewModel.Input(calendarMode: Observable.just((calendarMode)))
        
        let output = viewModel.tranform(input: input)
        
        output.workplaceInfoListRelay
            .map { [weak self] in
                if self?.calendarMode == .personal {
                    let staticWorkplace = Workplace(workplacesName: "",
                                                    category: "",
                                                    ownerId: "",
                                                    inviteCode: "",
                                                    isOfficial: false)
                    let staticWorkplaceInfo = WorkplaceInfo(id: "", workplace: staticWorkplace)
                    return [staticWorkplaceInfo] + $0
                } else {
                    return $0
                }
            }
            .asDriver(onErrorJustReturn: [])
            .do(afterNext: { [weak self] list in
                self?.filterView.getWorkplaceTableView.isHidden = list.isEmpty
                
                if !list.isEmpty {
                    if let prevFilterIndex = self?.prevFilterIndex {
                        self?.filterView.getWorkplaceTableView.selectRow(at: IndexPath(row: prevFilterIndex, section: 0), animated: false, scrollPosition: .middle)
                    } else {
                        self?.filterView.getWorkplaceTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .middle)
                    }
                }
            })
            .drive(filterView.getWorkplaceTableView.rx.items(
                cellIdentifier: WorkplaceCell.identifier, cellType: WorkplaceCell.self)) { [weak self] index, model, cell in
                    guard let model = model as? WorkplaceInfo else { return }
                    if self?.calendarMode == .personal && index == 0 {
                        cell.update(workplace: "전체 보기")
                    } else {
                        cell.update(workplace: model.workplace.workplacesName)
                    }
                    
                    if model.workplace.workplacesName == self?.prevFilterWorkplace {
                        self?.prevFilterIndex = index
                    }
                }.disposed(by: disposeBag)
    }
}
