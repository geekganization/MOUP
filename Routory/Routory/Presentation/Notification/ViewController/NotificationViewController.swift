//
//  NotificationViewController.swift
//  Routory
//
//  Created by 송규섭 on 6/15/25.
//

import UIKit
import RxSwift
import RxRelay

class NotificationViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: NotificationViewModel
    private let viewDidLoadRelay = PublishRelay<Void>()
    private let input: NotificationViewModel.Input
    private let output: NotificationViewModel.Output

    // MARK: - UI Components
    private let notificationView = NotificationView()

    // MARK: - loadView
    override func loadView() {
        view = notificationView
    }

    init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        self.input = NotificationViewModel.Input(viewDidLoad: viewDidLoadRelay)
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

        configure()
        viewDidLoadRelay.accept(())
    }
}

private extension NotificationViewController {
    func configure() {
        setStyles()
        setBindings()
    }

    func setStyles() {
        view.backgroundColor = .primaryBackground
    }

    func setBindings() {        
//        viewDidLoadRelay.accept(())

        notificationView.rx.setDelegates
            .onNext(self)

//        output.notifications.bind(to: notificationView.rx.bindItems)
//            .disposed(by: disposeBag)
        
        output.notifications
            .bind(to: notificationView.rx.bindItems)
            .disposed(by: disposeBag)

        notificationView.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
