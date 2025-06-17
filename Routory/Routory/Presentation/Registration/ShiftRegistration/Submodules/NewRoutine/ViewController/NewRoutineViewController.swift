//
//  NewRoutineViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import FirebaseAuth

enum RoutineFormMode {
    case create
    case edit(routineId: String, existingTitle: String, existingTime: String, existingTasks: [String])
    case read(existingTitle: String, existingTime: String, existingTasks: [String])
}

final class NewRoutineViewController: UIViewController {

    // MARK: - ViewModel & Rx

    private let viewModel: NewRoutineViewModel
    private let saveTrigger = PublishSubject<Routine>()
    private let disposeBag = DisposeBag()
    
    private lazy var navigationBar = BaseNavigationBar(title: modeTitle())
    
    // MARK: - Mode & State

    private let mode: RoutineFormMode
    private var tasks: [String] = []

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleTextField = UITextField().then {
        $0.placeholder = "제목을 입력해 주세요"
        $0.borderStyle = .roundedRect
        $0.font = .systemFont(ofSize: 16)
    }

    private let alarmField = AlarmTimeFieldView()

    private let taskLabel = UILabel().then {
        $0.text = "할 일 리스트"
        $0.font = .boldSystemFont(ofSize: 14)
    }

    private let taskInputField = UITextField().then {
        $0.placeholder = "할 일을 입력해 주세요"
        $0.borderStyle = .roundedRect
        $0.font = .systemFont(ofSize: 14)
    }

    private let addTaskButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = .gray
    }

    private let tableView = UITableView().then {
        $0.isScrollEnabled = false
        $0.separatorStyle = .none
        $0.rowHeight = 44
        $0.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
    }

    // MARK: - Init

    init(mode: RoutineFormMode) {
        self.mode = mode

        let useCase = RoutineUseCase(repository: RoutineRepository(service: RoutineService()))
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        switch mode {
        case .create:
            self.viewModel = NewRoutineViewModel(useCase: useCase, uid: uid, mode: .create)
        case .edit(let routineId, _, _, _):
            self.viewModel = NewRoutineViewModel(useCase: useCase, uid: uid, mode: .edit(routineId: routineId))
        case .read:
            self.viewModel = NewRoutineViewModel(useCase: useCase, uid: uid, mode: .read)
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        layout()
        applyMode()
        bindViewModel()
    }

    // MARK: - Setup UI
    
    private func setupNavigationBar() {
        navigationBar.rx.backBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        navigationBar.rx.rightBtnTapped
            .subscribe(onNext: { [weak self] in
                self?.didTapSave()
            })
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = modeTitle()

        if case .read = mode {
            navigationBar.configureRightButton(icon: nil, title: nil)
        } else {
            navigationBar.configureRightButton(icon: nil, title: "저장")

        }

        addTaskButton.addTarget(self, action: #selector(didTapAddTask), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAlarmField))
        alarmField.addGestureRecognizer(tap)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true

        view.addSubview(navigationBar)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleTextField, alarmField, taskLabel, taskInputField, addTaskButton, tableView].forEach {
            contentView.addSubview($0)
        }
    }

    private func layout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        titleTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

        alarmField.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(titleTextField)
            $0.height.equalTo(44)
        }

        taskLabel.snp.makeConstraints {
            $0.top.equalTo(alarmField.snp.bottom).offset(24)
            $0.leading.equalTo(titleTextField)
        }

        taskInputField.snp.makeConstraints {
            $0.top.equalTo(taskLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleTextField)
            $0.height.equalTo(36)
        }

        addTaskButton.snp.makeConstraints {
            $0.leading.equalTo(taskInputField.snp.trailing).offset(8)
            $0.trailing.equalTo(titleTextField)
            $0.centerY.equalTo(taskInputField)
            $0.width.height.equalTo(24)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(taskInputField.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(titleTextField)
            $0.height.equalTo(44 * max(tasks.count, 1))
            $0.bottom.equalToSuperview().offset(-40)
        }
    }

    // MARK: - Bind ViewModel

    private func bindViewModel() {
        let input = NewRoutineViewModel.Input(saveTrigger: saveTrigger.asObservable())
        let output = viewModel.transform(input: input)

        output.didSaveRoutine
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
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

    // MARK: - Actions

    @objc private func didTapAddTask() {
        guard let text = taskInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        tasks.append(text)
        taskInputField.text = nil
        tableView.reloadData()
        tableView.snp.updateConstraints {
            $0.height.equalTo(44 * max(tasks.count, 1))
        }
    }

    @objc private func didTapSave() {
        let trimmedTitle = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let alarmTime = alarmField.getLabel()

        guard !trimmedTitle.isEmpty else {
            let alert = UIAlertController(title: nil, message: "제목을 입력해 주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }

        let routine = Routine(routineName: trimmedTitle, alarmTime: alarmTime, tasks: tasks)
        saveTrigger.onNext(routine)
    }

    @objc private func didTapAlarmField() {
        guard case .read = mode else {
            presentTimePicker()
            return
        }
    }

    private func presentTimePicker() {
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)

        let picker = UIDatePicker().then {
            $0.datePickerMode = .time
            $0.preferredDatePickerStyle = .wheels
            $0.locale = Locale(identifier: "ko_KR")
        }

        alert.view.addSubview(picker)
        picker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let selectedTime = formatter.string(from: picker.date)
            self?.alarmField.update(text: selectedTime)
        }))

        present(alert, animated: true)
    }

    // MARK: - Mode Handling

    private func applyMode() {
        switch mode {
        case .create:
            title = "새 루틴"
        case .edit(let routineId,let existingTitle, let existingTime, let existingTasks):
            title = "루틴 편집"
            titleTextField.text = existingTitle
            alarmField.update(text: existingTime)
            tasks = existingTasks
            tableView.reloadData()
            tableView.snp.updateConstraints {
                $0.height.equalTo(44 * tasks.count)
            }
        case .read(let existingTitle, let existingTime, let existingTasks):
            title = "루틴 보기"
            titleTextField.text = existingTitle
            alarmField.update(text: existingTime)
            tasks = existingTasks

            titleTextField.isEnabled = false
            alarmField.isUserInteractionEnabled = false
            taskInputField.isEnabled = false
            addTaskButton.isHidden = true
            tableView.isEditing = false
        }

        tableView.snp.updateConstraints {
            $0.height.equalTo(44 * max(tasks.count, 1))
        }
    }

    private func modeTitle() -> String {
        switch mode {
        case .create: return "새 루틴"
        case .edit: return "루틴 편집"
        case .read: return "루틴 보기"
        }
    }
}

// MARK: - UITableViewDataSource

extension NewRoutineViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = tasks.remove(at: sourceIndexPath.row)
        tasks.insert(moved, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        cell.configure(text: tasks[indexPath.row])
        return cell
    }
}
