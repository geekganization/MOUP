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
    private let refreshTriggeredRelay = PublishRelay<Void>()
    private let deleteRoutineRelay = PublishRelay<String>()

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

        self.input = ManageRoutineViewModel.Input(
            refreshTriggered: refreshTriggeredRelay.asObservable(),
            deleteRoutineTriggered: deleteRoutineRelay.asObservable()
        )
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


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
        manageRoutineView.tableView.delegate = self

        manageRoutineView.rx.backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        switch routineType {
        case .today:
            // 오늘의 루틴: 매장별 루틴 개수 표시
            output.todaysRoutine
                .bind(to: manageRoutineView.tableView.rx.items(
                    cellIdentifier: TodaysRoutineCell.identifier,
                    cellType: TodaysRoutineCell.self
                )) { index, routine, cell in
                    print("오늘의 루틴: \(routine)")
                    cell.update(with: routine)
                }
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
                .bind(to: manageRoutineView.tableView.rx.items(
                    cellIdentifier: CommonRoutineCell.identifier,
                    cellType: CommonRoutineCell.self
                )) { index, routine, cell in
                    cell.update(with: routine.routine)
                }
                .disposed(by: disposeBag)

            manageRoutineView.rx.itemSelected
                .withLatestFrom(output.allRoutine) { indexPath, routines in
                    return routines[indexPath.row]
                }
                .subscribe(onNext: { [weak self] routine in
                    print("\(routine) 루틴 탭")
                    let vc = NewRoutineViewController(mode: .read(
                        existingTitle: routine.routine.routineName,
                        existingTime: routine.routine.alarmTime,
                        existingTasks: routine.routine.tasks
                    ))
                    self?.navigationController?.pushViewController(vc, animated: true)
                })
                .disposed(by: disposeBag)

            manageRoutineView.rx.rightButtonTapped
                .subscribe(onNext: { [weak self] in
                    guard let self else { return }
                    let vc = NewRoutineViewController(mode: .create)
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                .disposed(by: disposeBag)
        }

        refreshTriggeredRelay.accept(())
    }
}

extension ManageRoutineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard routineType == .all else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            self.output.allRoutine
                .take(1)
                .subscribe(onNext: { [weak self] routines in
                    guard let self else {
                        completion(false)
                        return
                    }
                    let routine = routines[indexPath.row]
                    self.deleteRoutineRelay.accept(routine.id)

                    completion(true)
                })
                .disposed(by: disposeBag)
        }

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])

        return configuration
    }
}
