//
//  SimpleRowView.swift
//  Routory
//
//  Created by tlswo on 6/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Protocol

protocol WorkPlaceSelectionViewDelegate: AnyObject {
    func workPlaceSelectionViewDidTapChevron(_ view: WorkPlaceSelectionView)
}

// MARK: - SimpleRowView

final class WorkPlaceSelectionView: UIView {

    // MARK: - Properties

    weak var delegate: WorkPlaceSelectionViewDelegate?

    // MARK: - UI Components
    
    private var workplaceID: String = ""

    private let titleLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.text = "근무지 선택"
        $0.textColor = .gray900
    }

    private let chevronImageView = UIImageView().then {
        $0.image = UIImage(named: "ChevronRight")
        $0.tintColor = .gray700
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
        $0.snp.makeConstraints { $0.size.equalTo(CGSize(width: 8, height: 14)) }
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = UIColor.systemGray4
    }

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        setupLayout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(chevronImageView)
        addSubview(separatorView)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        separatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }

        self.snp.makeConstraints {
            $0.height.equalTo(44)
        }
    }

    // MARK: - Gesture

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(chevronTapped))
        self.addGestureRecognizer(tap)
    }

    @objc private func chevronTapped() {
        delegate?.workPlaceSelectionViewDidTapChevron(self)
    }

    // MARK: - Public API

    func updateTitle(_ title: String) {
        titleLabel.text = title
    }

    func getData() -> String {
        return titleLabel.text ?? ""
    }
    
    func updateID(_ id: String) {
        self.workplaceID = id
    }
    
    func getID() -> String {
        return self.workplaceID
    }
}
