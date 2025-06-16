//
//  RoutineView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Protocol

protocol RoutineViewDelegate: AnyObject {
    func routineViewDidTapAdd()
}

// MARK: - RoutineView

final class RoutineView: UIView, ValueRowViewDelegate {

    // MARK: - Properties

    weak var delegate: RoutineViewDelegate?
    
    private var routines: [Routine] = []

    private let addRow = ValueRowView(title: "루틴 추가", value: nil)

    // MARK: - Initializer

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        addRow.delegate = self

        let titleLabel = UILabel().then {
            $0.text = "루틴"
            $0.font = .headBold(18)
        }

        let box = makeBoxedStackView(with: [addRow])

        let stack = UIStackView(arrangedSubviews: [titleLabel, box]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - ValueRowViewDelegate

    func valueRowViewDidTapChevron(_ row: ValueRowView) {
        delegate?.routineViewDidTapAdd()
    }

    // MARK: - Public API
    
    func updateSelectedRoutineData(_ routines: [Routine]) {
        self.routines = routines
    }

    func updateSelectedRoutine(_ name: String) {
        addRow.updateTitle(name)
    }
    
    func updateCounterLabel(_ name: String){
        addRow.updatePlusLabel(value: name)
    }

    func getTitleData() -> String {
        return addRow.getTitleData()
    }
    
    func getSelectedRoutineData() -> [Routine] {
        return self.routines
    }
    
    func getSelectedRoutineIDs() -> [String] {
        return routines.map { $0.id }
    }
}
