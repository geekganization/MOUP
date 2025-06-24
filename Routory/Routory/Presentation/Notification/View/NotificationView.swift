//
//  NotificationView.swift
//  Routory
//
//  Created by 송규섭 on 6/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationView: UIView {
    // MARK: - Properties
    fileprivate let disposeBag = DisposeBag()

    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "알림")

    fileprivate let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.register(CommonNotificationCell.self, forCellReuseIdentifier: CommonNotificationCell.identifier)
        $0.register(ApprovalNotificationCell.self, forCellReuseIdentifier: ApprovalNotificationCell.identifier)
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
}

private extension NotificationView {
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
        backgroundColor = .primaryBackground
    }

    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

extension Reactive where Base: NotificationView {
    var setDelegates: Binder<UITableViewDelegate> {
        return Binder(base) { view, delegate in
            view.tableView.delegate = nil
            view.tableView.rx.setDelegate(delegate)
                .disposed(by: view.disposeBag)
        }
    }

    var bindItems: Binder<[DummyNotification]> {
        return Binder(base) { view, notifications in
            view.tableView.dataSource = nil
            Observable.just(notifications)
                .bind(to: view.tableView.rx.items) { tableView, index, notification in
                    switch notification.type {
                    case .common:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommonNotificationCell.identifier, for: IndexPath(row: index, section: 0)) as? CommonNotificationCell else {
                            return UITableViewCell()
                        }
                        cell.update(with: notification)
                        return cell
                    case .approval(let status):
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: ApprovalNotificationCell.identifier, for: IndexPath(row: index, section: 0)) as? ApprovalNotificationCell else {
                            return UITableViewCell()
                        }
                        cell.update(with: notification, type: status)
                        return cell
                    }
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
