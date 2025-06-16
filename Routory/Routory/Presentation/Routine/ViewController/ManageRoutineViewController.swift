//
//  ManageRoutineViewController.swift
//  Routory
//
//  Created by 송규섭 on 6/15/25.
//

import UIKit
import RxSwift
import RxRelay

enum RoutineType {
    case today
    case all

    var title: String {
        switch self {
        case .today:
            return "오늘의 루틴"
        case .all:
            return "전체 루틴"
        }
    }
}

class ManageRoutineViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ManageRoutineViewModel
    private let routineType: RoutineType
    private let disposeBag = DisposeBag()
    private let viewDidLoadRelay = PublishRelay<Void>()

    private let input: ManageRoutineViewModel.Input
    private let output: ManageRoutineViewModel.Output

    // MARK: - UI Components
    private lazy var manageRoutineView = ManageRoutineView(title: routineType.title)

    override func loadView() {
        view = manageRoutineView
    }

    init(routineType: RoutineType, viewModel: ManageRoutineViewModel) {
        self.routineType = routineType
        self.viewModel = viewModel

        self.input = ManageRoutineViewModel.Input(viewDidLoad: viewDidLoadRelay)
        self.output = viewModel.transform(input: input)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

}

private extension ManageRoutineViewController {
    func configure() {
        setStyles()
        setBindings()
    }

    func setStyles() {
        manageRoutineView.update(by: routineType)
    }

    func setBindings() {
        viewDidLoadRelay.accept(())

        manageRoutineView.rx.backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        manageRoutineView.rx.setDelegate
            .onNext(self)

        switch routineType {
        case .today:
            // 오늘의 루틴: 매장별 루틴 개수 표시
            output.todaysRoutine
                .bind(to: manageRoutineView.rx.bindTodaysRoutines)
                .disposed(by: disposeBag)

            manageRoutineView.rx.itemSelected
                .withLatestFrom(output.todaysRoutine) { indexPath, routines in
                    return routines[indexPath.row]
                }
                .subscribe(onNext: { [weak self] routine in
                    print("해당 매장 루틴: \(routine)")
                    let vc = WorkplaceRoutineViewController(routine: routine)
                    self?.navigationController?.pushViewController(vc, animated: true)
                })
                .disposed(by: disposeBag)

        case .all:
            // 전체 루틴: 등록한 모든 루틴 표시
            output.allRoutine
                .bind(to: manageRoutineView.rx.bindAllRoutines)
                .disposed(by: disposeBag)

            manageRoutineView.rx.itemSelected
                .withLatestFrom(output.allRoutine) { indexPath, routines in
                    return routines[indexPath.row]
                }
                .subscribe(onNext: { [weak self] routine in
                    print("\(routine) 루틴 탭")
                    let vc = NewRoutineViewController(mode: .create)
                    self?.navigationController?.pushViewController(vc, animated: true)
                })
                .disposed(by: disposeBag)
        }


    }
}

extension ManageRoutineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}
