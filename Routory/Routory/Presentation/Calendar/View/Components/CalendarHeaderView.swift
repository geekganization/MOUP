//
//  CalendarHeaderView.swift
//  Routory
//
//  Created by 서동환 on 6/10/25.
//

import UIKit

import BetterSegmentedControl
import SnapKit
import Then

final class CalendarHeaderView: UIView {
    
    // MARK: - UI Components
    
    /// 연.월 표시 및 `UIPickerView` 사용을 위한 `UIButton`
    private let yearMonthButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("2001.01", attributes: .init([.font: UIFont.headBold(20), .foregroundColor: UIColor.gray900]))
        config.image = .chevronRight.withTintColor(.gray900, renderingMode: .alwaysOriginal)
        config.imagePlacement = .trailing
        config.imagePadding = 8
        
        config.contentInsets = .zero
        
        $0.configuration = config
    }
    
    /// 토글 스위치 `BetterSegmentedControl` 라이브러리
    private let toggleSwitch = BetterSegmentedControl().then {
        $0.segments = LabelSegment.segments(withTitles: ["개인", "공유"],
                                            normalFont: .buttonSemibold(16),
                                            normalTextColor: .gray400,
                                            selectedFont: .buttonSemibold(16),
                                            selectedTextColor: .white)
        $0.setOptions([.cornerRadius(12.5),
                       .indicatorViewBackgroundColor(.gray700),
                       .backgroundColor(.gray100)])
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.borderWidth = 1
    }
    
    /// 필터 `UIButton`
    private let filterButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "slider.horizontal.3")?.withTintColor(.gray700, renderingMode: .alwaysOriginal)
        config.contentInsets = .init(top: 12, leading: 10, bottom: 12, trailing: 10)
        
        $0.configuration = config
    }
    
    // MARK: - Getter
    
    var getYearMonthButton: UIButton { yearMonthButton }
    var getToggleSwitch: BetterSegmentedControl { toggleSwitch }
    var getFilterButton: UIButton { filterButton }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

// MARK: - UI Methods

private extension CalendarHeaderView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.addSubviews(yearMonthButton, toggleSwitch, filterButton)
    }
    
    func setStyles() {
        toggleSwitch.segments = LabelSegment.segments(withTitles: ["개인", "공유"],
                                                      normalFont: .buttonSemibold(16),
                                                      normalTextColor: .gray400,
                                                      selectedFont: .buttonSemibold(16),
                                                      selectedTextColor: .white)
        toggleSwitch.setOptions([.cornerRadius(12.5),
                                 .indicatorViewBackgroundColor(.gray700),
                                 .backgroundColor(.gray100)])
        toggleSwitch.layer.borderColor = UIColor.gray400.cgColor
        toggleSwitch.layer.borderWidth = 1
    }
    
    func setConstraints() {
        yearMonthButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        toggleSwitch.snp.makeConstraints {
            $0.trailing.equalTo(filterButton.snp.leading).offset(-2)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(90)
            $0.height.equalTo(25)
        }
        
        filterButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(5)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
    }
}
