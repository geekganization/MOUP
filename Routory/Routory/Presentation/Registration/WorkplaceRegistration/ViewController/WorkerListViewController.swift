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

final class WorkerListViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties

    private var workerList: [WorkerDetailInfo]
    private let tableView = UITableView()
    private let navigationBar = BaseNavigationBar(title: "알바생 관리")
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(workerList: [WorkerDetailInfo],workerPlaceId: String) {
        self.workerList = workerList
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
        layout()
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
}

// MARK: - UITableViewDataSource & Delegate

extension WorkerListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        workerList.count
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
        
        // workerList[indexPath].WorkerDetail로 접근해서 데이터들로 WorkerEditViewController 생성하기

        let vc = WorkerEditViewController(
            navigationTitle: "홍길동",
            salaryTypeValue: "매월",
            salaryCalcValue: "고정",
            fixedSalaryValue: "3,000,000",
            hourlyWageValue: "10,000",
            payDateValue: "25일",
            payWeekdayValue: "금요일",
            isFourMajorSelected: true,
            isNationalPensionSelected: true,
            isHealthInsuranceSelected: true,
            isEmploymentInsuranceSelected: true,
            isIndustrialAccidentInsuranceSelected: true,
            isIncomeTaxSelected: true,
            isWeeklyAllowanceSelected: false,
            isNightAllowanceSelected: true,
            labelTitle: "빨간색",
            showDot: true,
            dotColor: UIColor(red: 1, green: 0.18, blue: 0.33, alpha: 1)
        )

        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            workerList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            // 데이터(알바생) 삭제 로직
            // deleteOrLeaveWorkplace에다
            // workerplaceId랑 workerList[indexPath].id를 넘겨줘서 해당 데이터 삭제
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
}
