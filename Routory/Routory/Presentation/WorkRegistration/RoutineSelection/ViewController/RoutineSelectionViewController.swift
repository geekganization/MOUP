//
//  RoutineSelectionViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class RoutineSelectionViewController: UIViewController {
    
    var onSelect: ((Routine) -> Void)?

    private let routinesLabel = UILabel().then {
        $0.text = "오늘의 루틴을 선택해 주세요"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
    }

    private let tableView = UITableView().then {
        $0.separatorStyle = .singleLine
        $0.register(RoutineCell.self, forCellReuseIdentifier: "RoutineCell")
        $0.rowHeight = 52
    }

    private let applyButton = UIButton(type: .system).then {
        $0.setTitle("적용하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.backgroundColor = UIColor.primary500
        $0.layer.cornerRadius = 12
    }

    private var routines: [RoutineItem] = [
        RoutineItem(routine: Routine(id: "1", routineName: "오픈", alarmTime: "09:00", tasks: []), isSelected: true),
        RoutineItem(routine: Routine(id: "2", routineName: "포기", alarmTime: "15:00", tasks: []), isSelected: false),
        RoutineItem(routine: Routine(id: "3", routineName: "마감", alarmTime: "18:00", tasks: []), isSelected: false)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layout()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "루틴 선택"

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))

        view.addSubview(routinesLabel)
        view.addSubview(tableView)
        view.addSubview(applyButton)

        tableView.dataSource = self
        tableView.delegate = self

        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
    }

    private func layout() {
        routinesLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(routinesLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(applyButton.snp.top).offset(-16)
        }

        applyButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(52)
        }
    }

    @objc private func didTapApply() {
        if let selected = routines.first(where: { $0.isSelected }) {
            onSelect?(selected.routine)
        }
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapAdd() {
        let newRoutineVC = NewRoutineViewController(mode: .create)
        navigationController?.pushViewController(newRoutineVC, animated: true)
    }
}

extension RoutineSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        routines.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in routines.indices {
            routines[i].isSelected = (i == indexPath.row)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell", for: indexPath) as? RoutineCell else {
            return UITableViewCell()
        }

        let item = routines[indexPath.row]
        cell.configure(with: item)

        cell.onTapCheckbox = { [weak self] in
            guard let self else { return }
            for i in routines.indices {
                routines[i].isSelected = (i == indexPath.row)
            }
            tableView.reloadData()
        }

        cell.onTapChevron = { [weak self] in
            guard let self else { return }
            let routine = item.routine
            let editVC = NewRoutineViewController(
                mode: .edit(existingTitle: routine.routineName,existingTime: routine.alarmTime, existingTasks: routine.tasks)
            )
            navigationController?.pushViewController(editVC, animated: true)
        }

        return cell
    }
}
