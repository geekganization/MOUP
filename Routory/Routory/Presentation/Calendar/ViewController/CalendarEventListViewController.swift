//
//  CalendarEventListViewController.swift
//  Routory
//
//  Created by 서동환 on 6/14/25.
//

import UIKit

import RxCocoa
import RxSwift
import Then

final class CalendarEventListViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: CalendarEventListVCDelegate?
    
    private let viewModel: CalendarEventListViewModel
    
    private let disposeBag = DisposeBag()
    
    private let day: Int
    private let calendarMode: CalendarMode
    
    // MARK: - UI Components
    
    private let calendarEventListView = CalendarEventListView()
    
    // MARK: - Initializer
    
    init(viewModel: CalendarEventListViewModel, day: Int, calendarMode: CalendarMode) {
        self.viewModel = viewModel
        self.day = day
        self.calendarMode = calendarMode
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = calendarEventListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

// MARK: - UI Methods

private extension CalendarEventListViewController {
    func configure() {
        setStyles()
        setDelegates()
        setBinding()
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
        
        calendarEventListView.getTitleLabel.text = "\(day)일"
    }
    
    func setDelegates() {
        self.navigationController?.presentationController?.delegate = self
    }
    
    func setBinding() {
        let deleteEventIndexPathRelay = PublishRelay<IndexPath>()
        
        calendarEventListView.getEventTableView.rx.modelSelected(CalendarModel.self)
            .subscribe(with: self) { owner, model in
                if owner.calendarMode == .personal {
                    owner.delegate?.didTapEventCell(model: model)
                }
            }.disposed(by: disposeBag)
        
        calendarEventListView.getAssignButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.delegate?.didTapRegisterButton()
            }.disposed(by: disposeBag)
        
        let input = CalendarEventListViewModel.Input(loadEventList: Observable.just(()),
                                                     deleteEventIndexPath: deleteEventIndexPathRelay.asObservable())
        
        let output = viewModel.tranform(input: input)
        
        output.calendarModelListRelay.asDriver(onErrorJustReturn: [])
            .drive(calendarEventListView.getEventTableView.rx.items(
                cellIdentifier: EventCell.identifier, cellType: EventCell.self)) { [weak self] index, model, cell in
                    guard let self else { return }
                    cell.update(model: model, calendarMode: calendarMode)
                    
                    let deleteAction = UIAction(title: "삭제하기", attributes: .destructive) { _ in
                        let alert = UIAlertController(title: "근무 삭제", message: "\(model.workplaceName) 근무를 삭제할까요?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                            deleteEventIndexPathRelay.accept(IndexPath(row: index, section: 0))
                        }))
                        self.present(alert, animated: true)
                        
                    }
                    let menu = UIMenu(children: [deleteAction])
                    cell.getEllipsisButton.menu = menu
                    cell.getEllipsisButton.showsMenuAsPrimaryAction = true
                    
                }.disposed(by: disposeBag)
        
        output.deleteEventResultRelay.asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, deleted in
                if deleted {
                    owner.delegate?.didDeleteEvent()
                }
            }.disposed(by: disposeBag)
    }
}

extension CalendarEventListViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.presentationControllerDidDismiss()
    }
}
