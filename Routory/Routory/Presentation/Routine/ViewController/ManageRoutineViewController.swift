//
//  ManageRoutineViewController.swift
//  Routory
//
//  Created by 송규섭 on 6/15/25.
//

import UIKit
import RxSwift

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
    private let routineType: RoutineType
    private let disposeBag = DisposeBag()
    private lazy var manageRoutineView = ManageRoutineView(title: routineType.title)

    override func loadView() {
        view = manageRoutineView
    }

    init(routineType: RoutineType) {
        self.routineType = routineType
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

    }

    func setBindings() {
        manageRoutineView.rx.backButtonTapped
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        manageRoutineView.rx.setDelegate
            .onNext(self)

        manageRoutineView.rx.bindTodaysRoutines
            .onNext([DummyTodaysRoutine(workplaceName: "맥도날드", routines: [Routine(id: "", routineName: "", alarmTime: "", tasks: [])])])
    }
}

extension ManageRoutineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}
