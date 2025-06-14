//
//  WorkplaceTableHeaderView.swift
//  Routory
//
//  Created by 서동환 on 6/15/25.
//

import UIKit

import SnapKit
import Then

final class WorkplaceTableHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    static let identifier = String(describing: WorkplaceTableHeaderView.self)
    
    // MARK: - UI Componenets
    
    private let headerLabel = UILabel().then {
        // TODO: 알바생인지 사장님인지에 따라 바뀌어야 함
        $0.text = "나의 근무지"
        $0.textColor = .gray900
        $0.font = .headBold(16)
    }
    
    // MARK: - Initializer
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
    }
}

// MARK: - UI Methods

private extension WorkplaceTableHeaderView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.contentView.addSubview(headerLabel)
    }
    
    func setStyles() {
        self.contentView.backgroundColor = .primaryBackground
    }
    
    func setConstraints() {
        headerLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
