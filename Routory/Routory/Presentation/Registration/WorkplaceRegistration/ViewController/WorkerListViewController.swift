//
//  WorkerListViewController.swift
//  Routory
//
//  Created by tlswo on 6/24/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class WorkerListViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties

    private var workerList: [WorkerDetailInfo]
    private let workerPlaceId: String

    private let tableView = UITableView()
    private let navigationBar = BaseNavigationBar(title: "알바생 관리")
    private let disposeBag = DisposeBag()

    // ViewModel
    private let viewModel = WorkerListViewModel(
        workplaceUseCase: WorkplaceUseCase(
            repository: WorkplaceRepository(service: WorkplaceService())
        )
    )
    private let deleteTrigger = PublishSubject<(workplaceId: String, uid: String)>()

    // MARK: - Init

    init(workerList: [WorkerDetailInfo], workerPlaceId: String) {
        self.workerList = workerList
        self.workerPlaceId = workerPlaceId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
        layout()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    // MARK: - Setup

    private func setup() {
        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WorkerCell.self, forCellReuseIdentifier: "WorkerCell")
        tableView.tableFooterView = UIView()

        view.addSubview(navigationBar)
        view.addSubview(tableView)
    }

    private func setupNavigationBar() {
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func layout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        let input = WorkerListViewModel.Input(deleteTrigger: deleteTrigger.asObservable())
        let output = viewModel.transform(input: input)

        output.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isLoading in
                print("로딩 중: \(isLoading)")
            })
            .disposed(by: disposeBag)

        output.successMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { message in
                print(message)
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                print("에러: \(message)")
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Alert

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension WorkerListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workerList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkerCell", for: indexPath) as? WorkerCell else {
            return UITableViewCell()
        }
        let worker = workerList[indexPath.row]
        cell.configure(with: worker)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let worker = workerList[indexPath.row]

        let vc = WorkerEditViewController(
            workerPlaceId: workerPlaceId,
            workerDetail: worker.detail,
            labelTitle: "빨간색",
            showDot: true,
            dotColor: UIColor(red: 1, green: 0.18, blue: 0.33, alpha: 1)
        )

        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let worker = workerList[indexPath.row]
            workerList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            deleteTrigger.onNext((
                workplaceId: workerPlaceId,
                uid: worker.id
            ))
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
}
