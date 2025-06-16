//
//  NewRoutineViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - RoutineFormMode

enum RoutineFormMode {
    case create
    case edit(existingTitle: String, existingTime: String, existingTasks: [String])
    case read(existingTitle: String, existingTime: String, existingTasks: [String])
}

// MARK: - NewRoutineViewController

final class NewRoutineViewController: UIViewController {

    // MARK: - Properties

    private var mode: RoutineFormMode
    private var tasks: [String] = []

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleTextField = UITextField().then {
        $0.placeholder = "제목을 입력해 주세요"
        $0.borderStyle = .roundedRect
        $0.font = .fieldsRegular(16)
    }

    private let alarmField = AlarmTimeFieldView()

    private let taskLabel = UILabel().then {
        $0.text = "할 일 리스트"
        $0.font = .headBold(14)
    }

    private let taskInputField = UITextField().then {
        $0.placeholder = "할 일을 입력해 주세요"
        $0.borderStyle = .roundedRect
        $0.font = .systemFont(ofSize: 14)
    }

    private let addTaskButton = UIButton(type: .system).then {
        let image = UIImage(systemName: "plus")
        $0.setImage(image, for: .normal)
        $0.tintColor = .gray700
    }

    private let tableView = UITableView().then {
        $0.isScrollEnabled = false
        $0.separatorStyle = .none
        $0.rowHeight = 44
        $0.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
    }

    // MARK: - Initializers

    init(mode: RoutineFormMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layout()
        applyMode()
        setupNavigationBar()
    }

    // MARK: - Setup
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        backButton.tintColor = .gray700
        navigationItem.leftBarButtonItem = backButton

        if case .read = mode {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "저장",
                style: .done,
                target: self,
                action: #selector(didTapSave)
            )
            navigationItem.rightBarButtonItem?.tintColor = .gray700
        }
    }

    private func setupUI() {
        view.backgroundColor = .white

        addTaskButton.addTarget(self, action: #selector(didTapAddTask), for: .touchUpInside)

        tableView.dataSource = self
        tableView.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAlarmField))
        alarmField.addGestureRecognizer(tap)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleTextField, alarmField, taskLabel, taskInputField, addTaskButton, tableView].forEach {
            contentView.addSubview($0)
        }
    }

    // MARK: - Layout

    private func layout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
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
            $0.height.equalTo(44 * tasks.count)
            $0.bottom.equalToSuperview().offset(-40)
        }
    }

    // MARK: - Mode Application

    private func applyMode() {
        switch mode {
        case .create:
            title = "새 루틴"

        case .edit(let existingTitle, let existingTime, let existingTasks):
            title = "루틴 편집"
            titleTextField.text = existingTitle
            alarmField.update(text: existingTime)
            tasks = existingTasks

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

        tableView.reloadData()
        tableView.snp.updateConstraints {
            $0.height.equalTo(44 * tasks.count)
        }
    }

    // MARK: - Actions
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapAddTask() {
        guard let text = taskInputField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        tasks.append(text)
        taskInputField.text = nil
        tableView.reloadData()
        tableView.snp.updateConstraints {
            $0.height.equalTo(44 * tasks.count)
        }
    }

    @objc private func didTapSave() {
        switch mode {
        case .create:
            let title = titleTextField.text ?? ""
            let alarmTime = alarmField.getLabel()
            dump(Routine(routineName: title, alarmTime: alarmTime, tasks: tasks))

        case .edit(let existingTitle, _, _):
            let updatedTitle = (titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                ? titleTextField.text!
                : existingTitle
            let updatedTime = alarmField.getLabel()
            let updatedTasks = tasks
            dump(Routine(routineName: updatedTitle, alarmTime: updatedTime, tasks: updatedTasks))

        case .read:
            break
        }
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
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension NewRoutineViewController: UITableViewDataSource, UITableViewDelegate {

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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if case .read = mode {
            return false
        }
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.snp.updateConstraints {
            $0.height.equalTo(44 * tasks.count)
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if case .read = mode {
            return false
        }
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = tasks.remove(at: sourceIndexPath.row)
        tasks.insert(moved, at: destinationIndexPath.row)
    }
}
