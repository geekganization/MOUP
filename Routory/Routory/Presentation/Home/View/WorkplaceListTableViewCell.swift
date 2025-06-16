//
//  WorkplaceListTableViewCell.swift
//  Routory
//
//  Created by shinyoungkim on 6/16/25.
//

import UIKit
import Then
import SnapKit

final class WorkplaceListTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let id = "WorkplaceListTableViewCell"
    
    // MARK: - UI Components
    
    private let checkBox = UIImageView().then {
        $0.image = UIImage.checkboxUnselected
    }
    
    private let workplaceName = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let seperator = UIView().then {
        $0.backgroundColor = .gray300
    }

    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(workplace: DummyWorkplace) {
        checkBox.image = workplace.isSelected ? UIImage.checkboxSelected : UIImage.checkboxUnselected
        workplaceName.text = workplace.name
    }

}

private extension WorkplaceListTableViewCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            checkBox,
            workplaceName,
            seperator
        )
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        checkBox.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        workplaceName.snp.makeConstraints {
            $0.leading.equalTo(checkBox.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        
        seperator.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
