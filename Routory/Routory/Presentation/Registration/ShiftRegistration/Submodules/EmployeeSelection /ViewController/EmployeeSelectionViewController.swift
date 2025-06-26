//
//  EmployeeSelectionViewController.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

// MARK: - Model

struct Employee {
    let id: String
    let name: String
    var isSelected: Bool
}

// MARK: - EmployeeSelectionViewController

final class EmployeeSelectionViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties

    private var employees: [Employee] = []

    var onSelect: (([Employee]) -> Void)?

    private let disposeBag = DisposeBag()
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let workplaceIdSubject = BehaviorSubject<String>(value: "")
    private var viewModel: EmployeeSelectionViewModel = EmployeeSelectionViewModel(workplaceUseCase: WorkplaceUseCase(repository: WorkplaceRepository(service: WorkplaceService())))

    // workplaceId 설정 메서드
    func setWorkplaceId(_ id: String) {
        workplaceIdSubject.onNext(id)
    }

    // MARK: - UI Components

    fileprivate lazy var navigationBar = BaseNavigationBar(title: "인원 선택")

    private let titleLabel = UILabel().then {
        $0.text = "근무할 알바생을 선택해 주세요"
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }

    private let tableView = UITableView().then {
        $0.separatorStyle = .singleLine
        $0.rowHeight = 52
        $0.register(EmployeeCell.self, forCellReuseIdentifier: "EmployeeCell")
    }

    private let applyButton = UIButton(type: .system).then {
        $0.setTitle("적용하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.backgroundColor = .primary500
        $0.layer.cornerRadius = 12
    }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        layout()
        bindViewModelIfReady()
        viewDidLoadSubject.onNext(())
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(navigationBar)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(applyButton)

        tableView.dataSource = self
        tableView.delegate = self

        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
    }

    private func bindViewModelIfReady() {
        let input = EmployeeSelectionViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            workplaceId: workplaceIdSubject.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.workerList
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] workerList in
                self?.employees = workerList.map {
                    Employee(
                        id: $0.id,
                        name: $0.detail.workerName,
                        isSelected: false
                    )
                }
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        output.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                print("Error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Layout

    private func layout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(applyButton.snp.top).offset(-16)
        }

        applyButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(52)
        }
    }

    // MARK: - Actions

    @objc private func didTapApply() {
        let selected = employees.filter { $0.isSelected }
        guard !selected.isEmpty else { return }
        onSelect?(selected)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension EmployeeSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        employees.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        employees[indexPath.row].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as? EmployeeCell else {
            return UITableViewCell()
        }

        let employee = employees[indexPath.row]
        cell.configure(with: employee)

        cell.onTapCheckbox = { [weak self] in
            self?.employees[indexPath.row].isSelected.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        return cell
    }
}
