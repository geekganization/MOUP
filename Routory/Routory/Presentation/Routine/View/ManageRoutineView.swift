//
//  ManageRoutineView.swift
//  Routory
//
//  Created by 송규섭 on 6/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ManageRoutineView: UIView {
    // MARK: - Properties
    private let routineTitle: String
    fileprivate let disposeBag = DisposeBag()

    // MARK: - UI Components
    fileprivate lazy var navigationBar = BaseNavigationBar(title: routineTitle)
    fileprivate let tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorColor = .gray300
        $0.separatorInset = .zero
        $0.register(CommonRoutineCell.self, forCellReuseIdentifier: CommonRoutineCell.identifier)
        $0.register(TodaysRoutineCell.self, forCellReuseIdentifier: TodaysRoutineCell.identifier)
    }

    // MARK: - Initializer
    init(title: String) {
        self.routineTitle = title
        super.init(frame: .zero)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
}

private extension ManageRoutineView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(navigationBar, tableView)
    }

    // MARK: - setStyles
    func setStyles() {
        self.backgroundColor = .primaryBackground
    }

    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(20)
            $0.directionalHorizontalEdges.bottom.equalToSuperview()
        }
    }
}

extension Reactive where Base: ManageRoutineView {
    var backButtonTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }

    var rightButtonTapped: ControlEvent<Void> {
        return base.navigationBar.rx.rightBtnTapped
    }

    var setDelegate: Binder<UITableViewDelegate> {
        return Binder(base) { view, delegate in
            view.tableView.delegate = delegate
        }
    }

    var bindAllRoutines: Binder<[Routine]> {
        return Binder(base) { view, routines in
            Observable.just(routines)
                .bind(to: view.tableView.rx.items) { tableView, index, routine in
                    let indexPath = IndexPath(row: index, section: 0)

                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: CommonRoutineCell.identifier,
                        for: indexPath
                    ) as? CommonRoutineCell else {
                        return UITableViewCell()
                    }
                    //                         cell.update(with: routine)

                    return cell
                }
                .disposed(by: view.disposeBag) // 적절한 disposeBag 사용 필요
        }
    }

    var bindTodaysRoutines: Binder<[DummyTodaysRoutine]> {
        return Binder(base) { view, routines in
            Observable.just(routines)
                .bind(to: view.tableView.rx.items) { tableView, index, routine in
                    let indexPath = IndexPath(row: index, section: 0)

                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: TodaysRoutineCell.identifier,
                        for: indexPath
                    ) as? TodaysRoutineCell else {
                        return UITableViewCell()
                    }
                     cell.update(with: routine)


                    return cell
                }.disposed(by: view.disposeBag)
        }
    }
}
