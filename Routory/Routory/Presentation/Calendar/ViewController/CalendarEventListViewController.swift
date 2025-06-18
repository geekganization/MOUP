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
    
    // MARK: - UI Components
    
    private let calendarEventListView = CalendarEventListView()
    
    // MARK: - Initializer
    
    init(viewModel: CalendarEventListViewModel, day: Int) {
        self.viewModel = viewModel
        self.day = day
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
        calendarEventListView.getEventTableView.rx.itemSelected
            .subscribe(with: self) { owner, indexPath in
                
                owner.delegate?.didTapEventCell()
            }.disposed(by: disposeBag)
        
        calendarEventListView.getAssignButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.delegate?.didTapAssignButton()
            }.disposed(by: disposeBag)
        
        let input = CalendarEventListViewModel.Input(viewDidLoad: Observable.just(()))
        
        let output = viewModel.tranform(input: input)
        
        output.eventListRelay.asDriver(onErrorJustReturn: [])
            .drive(calendarEventListView.getEventTableView.rx.items( 
                cellIdentifier: EventCell.identifier, cellType: EventCell.self)) { _, model, cell in
                    cell.update(workplace: model.title, startTime: model.startTime, endTime: model.endTime, dailyWage: "", isShared: false)
                }.disposed(by: disposeBag)
    }
}

extension CalendarEventListViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.presentationControllerDidDismiss()
    }
}
