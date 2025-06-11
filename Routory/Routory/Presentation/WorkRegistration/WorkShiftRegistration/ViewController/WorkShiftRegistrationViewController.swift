//
//  WorkShiftRegistrationViewController.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class WorkShiftRegistrationViewController: UIViewController {
    
    private let simpleRowView = SimpleRowView()
    private let routineView = RoutineView()
    private let workDateView = WorkDateView()
    private let labelView = LabelView()
    private lazy var workTimeView = WorkTimeView()
    private let memoBoxView = MemoBoxView()
    
    private let scrollView = UIScrollView().then {
        $0.keyboardDismissMode = .interactive
    }
    
    private let contentStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
        $0.alignment = .fill
    }
    
    private let registerButton = UIButton(type: .system).then {
        $0.setTitle("등록하기", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.backgroundColor = UIColor.systemGray5
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.layer.cornerRadius = 8
        $0.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layout()
    }
    
    private func setupUI() {
        title = "근무 등록"
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        simpleRowView.delegate = self
        routineView.delegate = self
        workDateView.delegate = self
        labelView.delegate = self
        workTimeView.delegate = self
        
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        contentStack.addArrangedSubview(simpleRowView)
        contentStack.addArrangedSubview(workDateView)
        contentStack.addArrangedSubview(workTimeView)
        contentStack.addArrangedSubview(routineView)
        contentStack.addArrangedSubview(labelView)
        contentStack.addArrangedSubview(memoBoxView)
        contentStack.addArrangedSubview(registerButton)
    }
    
    private func layout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentStack.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.frameLayoutGuide).inset(16)
        }
        
        registerButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }
    
    @objc func didTapRegister() {
        print(simpleRowView.getData())
        print(routineView.getTitleData())
        print(workDateView.getdateRowData())
        print(workDateView.getrepeatRowData())
        print(labelView.getColorData())
        print(labelView.getColorLabelData())
        print(workTimeView.getstartRowData())
        print(workTimeView.getrestRowData())
        print(workTimeView.getendRowData())
        print(memoBoxView.getData())
    }
}

extension WorkShiftRegistrationViewController: SimpleRowViewDelegate {
    func simpleRowViewDidTapChevron(_ view: SimpleRowView) {
        let vc = WorkplaceSelectionViewController()
        vc.onSelect = { [weak self] workplace in
            self?.simpleRowView.updateTitle(workplace.workplacesName)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension WorkShiftRegistrationViewController: RoutineViewDelegate {
    func routineViewDidTapAdd() {
        let vc = RoutineSelectionViewController()
        vc.onSelect = { [weak self] routine in
            self?.routineView.updateSelectedRoutine(routine.routineName)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension WorkShiftRegistrationViewController: LabelViewDelegate {
    func labelViewDidTapSelectColor(_ sender: LabelView) {
        let vc = ColorSelectionViewController()
        vc.onSelect = { [weak self] labelColor in
            self?.labelView.updateLabelName(labelColor.name, color: labelColor.color)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension WorkShiftRegistrationViewController: WorkDateViewDelegate {
    func didTapRepeatRow(from view: WorkDateView) {
        let vc = RepeatDaysViewController()
        vc.onSelectDays = { [weak view] shortLabel in
            view?.updateRepeatValue(shortLabel)  
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapDateRow(completion: @escaping (Date) -> Void) {
        let alert = UIAlertController(title: "날짜 선택", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)

        let datePicker = UIDatePicker().then {
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .wheels
            $0.frame = CGRect(x: 0, y: 30, width: alert.view.bounds.width - 20, height: 160)
        }

        alert.view.addSubview(datePicker)

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completion(datePicker.date)
        }))

        present(alert, animated: true)
    }
}

extension WorkShiftRegistrationViewController: WorkTimeViewDelegate {

    func workTimeViewDidRequestTimePicker(for type: WorkTimeView.TimeType, current: String) {
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: current) {
            picker.date = date
        }

        alert.view.addSubview(picker)
        picker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            let newValue = formatter.string(from: picker.date)
            self?.workTimeView.updateValue(for: type, newValue: newValue)
        }))

        present(alert, animated: true)
    }

    func workTimeViewDidRequestBreakTimePicker(current: String) {
        let vc = BreakTimePickerViewController()
        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        vc.onSelect = { [weak self] index in
            let minutes = (index + 1) * 30
            let hour = minutes / 60
            let minute = minutes % 60
            let text = hour > 0 ? "\(hour)시간\(minute > 0 ? " \(minute)분" : "")" : "\(minute)분"
            self?.workTimeView.updateRestValue(text)
        }

        present(vc, animated: true)
    }
}
