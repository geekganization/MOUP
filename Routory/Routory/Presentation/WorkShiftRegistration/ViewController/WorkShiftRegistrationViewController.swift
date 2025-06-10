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
        $0.isEnabled = false
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
        
        contentStack.addArrangedSubview(simpleRowView)
        contentStack.addArrangedSubview(WorkDateView())
        contentStack.addArrangedSubview(WorkTimeView())
        contentStack.addArrangedSubview(RoutineView())
        contentStack.addArrangedSubview(LabelView())
        contentStack.addArrangedSubview(MemoBoxView())
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
}

extension WorkShiftRegistrationViewController: SimpleRowViewDelegate {
    func simpleRowViewDidTapChevron(_ view: SimpleRowView) {
        let vc = WorkplaceSelectionViewController()
        vc.onSelect = { [weak self] (workplace: Workplace) in
            self?.simpleRowView.updateTitle(workplace.workplacesName)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
