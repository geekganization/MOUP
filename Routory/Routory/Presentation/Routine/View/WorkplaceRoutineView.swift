//
//  WorkplaceRoutineView.swift
//  Routory
//
//  Created by 송규섭 on 6/16/25.
//

import UIKit
import RxSwift
import RxCocoa

class WorkplaceRoutineView: UIView {
    // MARK: - Properties
    private let workplaceTitle: String
    fileprivate let disposeBag = DisposeBag()

    // MARK: - UI Components
    fileprivate lazy var navigationBar = BaseNavigationBar(title: workplaceTitle)
    fileprivate let tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorColor = .gray300
        $0.separatorInset = .zero
        $0.register(CommonRoutineCell.self, forCellReuseIdentifier: CommonRoutineCell.identifier)
    }

    // MARK: - Initializer
    init(title: String) {
        self.workplaceTitle = title
        super.init(frame: .zero)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func updateTitle(_ title: String) {
        navigationBar.configureTitle(title: title)
    }
}

private extension WorkplaceRoutineView {
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
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.directionalHorizontalEdges.bottom.equalToSuperview()
        }
    }
}

extension Reactive where Base: WorkplaceRoutineView {
    var bindItems: Binder<[RoutineInfo]> {
        return Binder(base) { view, routines in
            Observable.just(routines)
                .bind(to: view.tableView.rx.items(
                    cellIdentifier: CommonRoutineCell.identifier,
                    cellType: CommonRoutineCell.self
                )) { index, routineInfo, cell in
                    cell.update(with: routineInfo.routine)
                }
                .disposed(by: base.disposeBag)
        }
    }

    var backBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }

    var itemSelected: ControlEvent<IndexPath> {
        return base.tableView.rx.itemSelected
    }
}
