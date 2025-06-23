//
//  ValueRowView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

protocol ValueRowViewDelegate: AnyObject {
    func valueRowViewDidTapChevron(_ row: ValueRowView)
}

final class ValueRowView: UIView {

    weak var delegate: ValueRowViewDelegate?
    
    private var employees: [Employee] = []

    // MARK: - UI Components

    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    private let dotView = UIView().then {
        $0.layer.cornerRadius = 4
        $0.snp.makeConstraints { $0.size.equalTo(8) }
    }

    private let valueLabel = UILabel().then {
        $0.textColor = .gray700
        $0.font = .bodyMedium(16)
        $0.textAlignment = .right
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let plusLabel = UILabel().then {
        $0.textColor = .gray700
        $0.font = .bodyMedium(16)
        $0.text = ""
        $0.isHidden = true
    }

    private let arrow = UIImageView().then {
        $0.image = UIImage(named: "ChevronRight")
        $0.tintColor = .gray700
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
        $0.snp.makeConstraints { $0.size.equalTo(CGSize(width: 8, height: 14)) }
    }

    private lazy var leftStack = UIStackView(arrangedSubviews: [dotView, titleLabel]).then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
    }

    private lazy var mainStack = UIStackView(arrangedSubviews: [leftStack, valueLabel, plusLabel, arrow]).then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 8
    }

    // MARK: - Initializer

    init(title: String, value: String?, showDot: Bool = false, dotColor: UIColor? = nil) {
        super.init(frame: .zero)
        titleLabel.text = title
        valueLabel.text = value
        dotView.isHidden = !showDot
        if let color = dotColor {
            dotView.backgroundColor = color
        }
        setupLayout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {
        addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(44)
        }

        let separator = UIView().then {
            $0.backgroundColor = .systemGray5
        }
        addSubview(separator)
        separator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    // MARK: - Gesture

//    private func setupGesture() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleChevronTap))
//        arrow.addGestureRecognizer(tap)
//    }
//
//    @objc private func handleChevronTap() {
//        delegate?.valueRowViewDidTapChevron(self)
//    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleChevronTap))
        self.addGestureRecognizer(tap)
    }

    @objc private func handleChevronTap() {
        delegate?.valueRowViewDidTapChevron(self)
    }

    // MARK: - Public API
    
    func updateEmployeesData(_ employees: [Employee]) {
        self.employees = employees
    }
    
    func getEmployeesData() -> [Employee] {
        return self.employees
    }

    func updateTitle(_ name: String) {
        titleLabel.text = name
    }

    func updateValue(_ name: String) {
        valueLabel.text = name
    }

    func updateDotColor(_ color: UIColor) {
        dotView.backgroundColor = color
        dotView.isHidden = false
    }

    func updateDotHidden(_ hidden: Bool) {
        dotView.isHidden = hidden
    }
    
    func updatePlusLabel(value: String?) {
        if let value = value {
            plusLabel.text = value
            plusLabel.isHidden = false
        } else {
            plusLabel.isHidden = true
        }
    }

    func getValueData() -> String {
        return valueLabel.text ?? ""
    }

    func getTitleData() -> String {
        return titleLabel.text ?? ""
    }

    func getColorData() -> UIColor {
        return dotView.backgroundColor ?? .white
    }
    
    /// 화살표(> 아이콘)의 표시 여부를 설정합니다.
    /// - Parameter hidden: true일 경우 화살표를 숨기고, false일 경우 표시합니다.
    func updateArrowHidden(_ hidden: Bool) {
        arrow.isHidden = hidden
    }
}
