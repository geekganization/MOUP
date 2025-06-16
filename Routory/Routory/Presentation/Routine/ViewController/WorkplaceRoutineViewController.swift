//
//  WorkplaceRoutineViewController.swift
//  Routory
//
//  Created by 송규섭 on 6/16/25.
//

import UIKit
import RxSwift
import RxRelay

class WorkplaceRoutineViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: WorkplaceRoutineViewModel
    private let disposeBag = DisposeBag()
    private let viewDidLoadRelay = PublishRelay<Void>()

    private let input: WorkplaceRoutineViewModel.Input
    private let output: WorkplaceRoutineViewModel.Output

    // MARK: - UI Components
    private lazy var workplaceRoutineView = WorkplaceRoutineView(title: "")

    override func loadView() {
        view = workplaceRoutineView
    }

    // MARK: - Initializer
    init(routine: DummyTodaysRoutine) {
        self.viewModel = WorkplaceRoutineViewModel(workplaceRoutine: routine)
        self.input = WorkplaceRoutineViewModel.Input(viewDidLoad: viewDidLoadRelay)
        self.output = viewModel.transform(input: input)
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WorkplaceRoutine - viewDidLoad")
        configure()
    }

}

private extension WorkplaceRoutineViewController {
    func configure() {
        setStyles()
        setBindings()
    }

    func setStyles() {

    }

    func setBindings() {
        print("setBindings 시작")
        viewDidLoadRelay.accept(())
        print("accept 완료")
        output.workplaceTitle
            .take(1)
            .subscribe(onNext: { [weak self] title in
                self?.workplaceRoutineView.updateTitle(title)
            })
            .disposed(by: disposeBag)

        workplaceRoutineView.rx.backBtnTapped
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        print("output.routines 접근 시작")
        output.routines.bind(to: workplaceRoutineView.rx.bindItems)
            .disposed(by: disposeBag)

        workplaceRoutineView.rx.itemSelected
            .withLatestFrom(output.routines) { indexPath, routines in
                return routines[indexPath.row]
            }
            .subscribe(onNext: { [weak self] routine in
                let vc = NewRoutineViewController(mode: .edit(existingTitle: routine.routine.routineName, existingTime: routine.routine.alarmTime, existingTasks: routine.routine.tasks))
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
