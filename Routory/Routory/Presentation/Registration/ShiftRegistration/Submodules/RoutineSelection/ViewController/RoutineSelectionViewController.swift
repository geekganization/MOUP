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
import RxCocoa

final class RoutineSelectionViewController: UIViewController {

    // MARK: - ViewModel & Rx

    private let viewModel = RoutineSelectionViewModel(
        useCase: RoutineUseCase(repository: RoutineRepository(service: RoutineService())),
        uid: Auth.auth().currentUser?.uid ?? ""
    )
    private let fetchTrigger = PublishSubject<Void>()
    private let disposeBag = DisposeBag()

    // MARK: - Properties

    var onSelect: (([RoutineInfo]) -> Void)?
    private var routines: [RoutineItem] = []
    
    fileprivate lazy var navigationBar = BaseNavigationBar(title: "루틴 선택") //*2

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        fetchTrigger.onNext(())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        layout()
        bindViewModel()
        fetchTrigger.onNext(())
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        let input = RoutineSelectionViewModel.Input(fetchTrigger: fetchTrigger.asObservable())
        let output = viewModel.transform(input: input)

        output.routineItems
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] items in
                self?.routines = items
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] message in
                let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        navigationBar.configureRightButton(icon: .plus, title: nil)
        
        navigationBar.rx.rightBtnTapped
            .subscribe(onNext: { [weak self] in
                let newRoutineVC = NewRoutineViewController(mode: .create)
                self?.navigationController?.pushViewController(newRoutineVC, animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(navigationBar)
        view.addSubview(routinesLabel)
        view.addSubview(tableView)
        view.addSubview(applyButton)

        tableView.dataSource = self
        tableView.delegate = self

        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
    }

    // MARK: - Layout

    private func layout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        routinesLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(16)
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

    @objc private func didTapApply() {
        let selectedRoutines = routines.filter { $0.isSelected }.map { $0.routineInfo }
        guard !selectedRoutines.isEmpty else { return }
        onSelect?(selectedRoutines)
        navigationController?.popViewController(animated: true)
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
                    routineId: routineInfo.id,
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

