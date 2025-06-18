//
//  WorkplaceSearchResultView.swift
//  Routory
//
//  Created by shinyoungkim on 6/16/25.
//

import UIKit
import Then
import SnapKit

final class WorkplaceSearchResultView: UIView {

    // MARK: - UI Components
    
    private let workplaceNameLabel = UILabel().then {
        $0.text = "GS25 분당이매역점"
        $0.font = .headBold(18)
        $0.setLineSpacing(.headBold)
        $0.textColor = .gray900
    }
    
    private let workplaceCategoryLabel = UILabel().then {
        $0.text = "편의점"
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray900
    }
    
    private let selectWorkplaceIcon = UIImageView().then {
        $0.image = UIImage.calendar
    }
    
    private let selectWorkplaceLabel = UILabel().then {
        $0.text = "근무지 정보 등록하기"
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let rightArrowIcon = UIImageView().then {
        $0.image = UIImage.chevronRight
    }
    
    private let workplaceSelect = UIView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - Getter
    
    var workplaceSelectView: UIView { workplaceSelect }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(name: String, category: String) {
        workplaceNameLabel.text = name
        workplaceCategoryLabel.text = category
    }
}

private extension WorkplaceSearchResultView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        workplaceSelect.addSubviews(
            selectWorkplaceIcon,
            selectWorkplaceLabel,
            rightArrowIcon
        )
        
        addSubviews(
            workplaceNameLabel,
            workplaceCategoryLabel,
            workplaceSelect
        )
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        workplaceNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        
        workplaceCategoryLabel.snp.makeConstraints {
            $0.top.equalTo(workplaceNameLabel.snp.bottom)
            $0.leading.equalTo(workplaceNameLabel.snp.leading)
        }
        
        workplaceSelect.snp.makeConstraints {
            $0.top.equalTo(workplaceCategoryLabel.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        selectWorkplaceIcon.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.leading.equalToSuperview()
        }
        
        selectWorkplaceLabel.snp.makeConstraints {
            $0.leading.equalTo(selectWorkplaceIcon.snp.trailing).offset(12)
            $0.centerY.equalTo(selectWorkplaceIcon.snp.centerY)
        }
        
        rightArrowIcon.snp.makeConstraints {
            $0.trailing.equalTo(workplaceSelect.snp.trailing)
            $0.centerY.equalTo(selectWorkplaceIcon.snp.centerY)
        }
    }
}
