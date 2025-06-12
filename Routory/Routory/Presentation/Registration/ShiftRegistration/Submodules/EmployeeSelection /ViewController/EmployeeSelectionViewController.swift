//
//  EmployeeSelectionViewController.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Model

struct Employee {
    let id: String
    let name: String
    var isSelected: Bool
}

// MARK: - EmployeeSelectionViewController

final class EmployeeSelectionViewController: UIViewController {

    // MARK: - Properties

    private var employees: [Employee] = [
        Employee(id: "1", name: "이알바", isSelected: true),
        Employee(id: "2", name: "김알바", isSelected: false),
        Employee(id: "3", name: "최알바", isSelected: false)
    ]

    var onSelect: (([Employee]) -> Void)?

    // MARK: - UI Components

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        layout()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "인원 선택"
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        backButton.tintColor = .gray700
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(applyButton)

        tableView.dataSource = self
        tableView.delegate = self

        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
    }

    // MARK: - Layout

    private func layout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
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

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

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
