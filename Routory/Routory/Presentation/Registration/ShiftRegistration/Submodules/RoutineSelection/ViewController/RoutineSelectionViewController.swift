//
//  RoutineSelectionViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then
import FirebaseAuth
import RxSwift

// MARK: - RoutineSelectionViewController

final class RoutineSelectionViewController: UIViewController {

    // MARK: - Properties
    
    private let disposeBag = DisposeBag()

    var onSelect: (([RoutineInfo]) -> Void)?
    
//    private var routines: [RoutineItem] = [
//        RoutineItem(routineInfo: RoutineInfo(id: "1", routine: Routine(routineName: "오픈", alarmTime: "09:00", tasks: [])), isSelected: false),
//        RoutineItem(routineInfo: RoutineInfo(id: "2", routine: Routine(routineName: "포기", alarmTime: "15:00", tasks: [])), isSelected: false),
//        RoutineItem(routineInfo: RoutineInfo(id: "3", routine: Routine(routineName: "마감", alarmTime: "18:00", tasks: [])), isSelected: false)
//    ]
    
    private var routines: [RoutineItem] = []

    // MARK: - UI Components

    private let routinesLabel = UILabel().then {
        $0.text = "오늘의 루틴을 선택해 주세요"
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }

    private let tableView = UITableView().then {
        $0.separatorStyle = .singleLine
        $0.register(RoutineCell.self, forCellReuseIdentifier: "RoutineCell")
        $0.rowHeight = 52
    }

    private let applyButton = UIButton(type: .system).then {
        $0.setTitle("적용하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.backgroundColor = UIColor.primary500
        $0.layer.cornerRadius = 12
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        getRoutines()
        setupUI()
        setupNavigationBar()
        layout()
    }
    
    private func getRoutines() {
        let routineUseCase = RoutineUseCase(repository: RoutineRepository(service: RoutineService()))
        guard let uid = Auth.auth().currentUser?.uid else { return }

        routineUseCase.fetchAllRoutines(uid: uid)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] routineInfos in
                let items = routineInfos.map {
                    RoutineItem(routineInfo: $0, isSelected: false)
                }
                self?.routines = items
                self?.tableView.reloadData()

                for item in items {
                    let info = item.routineInfo
                    let routine = info.routine
                    print("ID: \(info.id), 이름: \(routine.routineName), 알람: \(routine.alarmTime)")
                }
            }, onError: { error in
                print("루틴 불러오기 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }


    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = "루틴 선택"
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        backButton.tintColor = .gray700
        navigationItem.rightBarButtonItem?.tintColor = .gray700
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupUI() {
        view.backgroundColor = .white

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAdd)
        )

        view.addSubview(routinesLabel)
        view.addSubview(tableView)
        view.addSubview(applyButton)

        tableView.dataSource = self
        tableView.delegate = self

        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
    }

    // MARK: - Layout

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

    // MARK: - Actions
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapApply() {
        let selectedRoutines = routines.filter { $0.isSelected }.map { $0.routineInfo }
        guard !selectedRoutines.isEmpty else { return }
        onSelect?(selectedRoutines)
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapAdd() {
        let newRoutineVC = NewRoutineViewController(mode: .create)
        navigationController?.pushViewController(newRoutineVC, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension RoutineSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        routines.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        routines[indexPath.row].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell", for: indexPath) as? RoutineCell else {
            return UITableViewCell()
        }

        let item = routines[indexPath.row]
        cell.configure(with: item)

        // MARK: - Cell Callbacks

        cell.onTapCheckbox = { [weak self] in
            guard let self else { return }
            routines[indexPath.row].isSelected.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        cell.onTapChevron = { [weak self] in
            guard let self else { return }
            let routineInfo = item.routineInfo
            let editVC = NewRoutineViewController(
                mode: .edit(
                    existingTitle: routineInfo.routine.routineName,
                    existingTime: routineInfo.routine.alarmTime,
                    existingTasks: routineInfo.routine.tasks
                )
            )
            navigationController?.pushViewController(editVC, animated: true)
        }

        return cell
    }
}
