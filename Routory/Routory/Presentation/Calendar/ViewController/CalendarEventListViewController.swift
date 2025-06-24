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
        
        calendarEventListView.getEventTableView.rx.itemSelected
            .subscribe(with: self) { owner, indexPath in
                owner.delegate?.didTapEventCell()
            }.disposed(by: disposeBag)
        
        calendarEventListView.getEventTableView.rx.itemDeleted
            .subscribe(with: self) { owner, indexPath in
                deleteEventIndexPathRelay.accept(indexPath)
            }.disposed(by: disposeBag)
        
        calendarEventListView.getAssignButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.delegate?.didTapAssignButton()
            }.disposed(by: disposeBag)
        
        let input = CalendarEventListViewModel.Input(loadEventList: Observable.just(()),
                                                     deleteEventIndexPath: deleteEventIndexPathRelay.asObservable())
        
        let output = viewModel.tranform(input: input)
        
        output.calendarModelListRelay.asDriver(onErrorJustReturn: [])
            .drive(calendarEventListView.getEventTableView.rx.items(
                cellIdentifier: EventCell.identifier, cellType: EventCell.self)) { [weak self] _, model, cell in
                    guard let self else { return }
                    let event = model.eventInfo.calendarEvent
                    cell.update(workplace: event.title, startTime: event.startTime, endTime: event.endTime, dailyWage: "", isOfficial: false, calendarMode: calendarMode)
                }.disposed(by: disposeBag)
    }
}

extension CalendarEventListViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.presentationControllerDidDismiss()
    }
}
