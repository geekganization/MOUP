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
    
    private let simpleRowView = SimpleRowView(title: "근무지 선택")
    private let routineView = RoutineView()
    private let workDateView = WorkDateView()
    private let labelView = LabelView()
    private lazy var workTimeView = WorkTimeView(presentingViewController: self)
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
        workDateView.parentViewController = self
        labelView.delegate = self
        
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
