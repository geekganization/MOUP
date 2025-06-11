//
//  WorkplaceSelectionViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - WorkplaceSelectionViewController

final class WorkplaceSelectionViewController: UIViewController {

    // MARK: - Properties

    var onSelect: ((Workplace) -> Void)?

    private var selectedIndex: Int?

    private let workplaces: [Workplace] = [
        Workplace(
            id: "1",
            workplacesName: "맥도날드",
            category: "패스트푸드",
            ownerId: "owner1",
            inviteCode: "ABCD1234",
            inviteCodeExpiresAt: "2025-07-31T23:59:59Z",
            isOfficial: true
        ),
        Workplace(
            id: "2",
            workplacesName: "쿠팡 야간",
            category: "물류",
            ownerId: "owner2",
            inviteCode: "EFGH5678",
            inviteCodeExpiresAt: "2025-08-01T23:59:59Z",
            isOfficial: false
        ),
        Workplace(
            id: "3",
            workplacesName: "올리브영",
            category: "뷰티",
            ownerId: "owner3",
            inviteCode: "IJKL9012",
            inviteCodeExpiresAt: "2025-08-05T23:59:59Z",
            isOfficial: true
        )
    ]

    // MARK: - UI Components

    private let titleLabel = UILabel().then {
        $0.text = "등록할 근무지를 선택해 주세요"
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }

    private let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(WorkplaceCell.self, forCellReuseIdentifier: "WorkplaceCell")
        $0.rowHeight = 64
    }

    private let applyButton = UIButton(type: .system).then {
        $0.setTitle("적용하기", for: .normal)
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.primary500
        $0.layer.cornerRadius = 12
        $0.isEnabled = true
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
        title = "근무지 선택"
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

        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(applyButton)

        applyButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    // MARK: - Layout

    private func layout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
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

    @objc private func didTapRegister() {
        guard let index = selectedIndex else { return }
        let selected = workplaces[index]
        onSelect?(selected)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension WorkplaceSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        workplaces.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkplaceCell", for: indexPath) as? WorkplaceCell else {
            return UITableViewCell()
        }

        let item = workplaces[indexPath.row]
        let isSelected = indexPath.row == selectedIndex
        cell.configure(with: item, selected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
}
