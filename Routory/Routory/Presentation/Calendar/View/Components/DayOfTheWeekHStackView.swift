//
//  DayOfTheWeekHStackView.swift
//  Routory
//
//  Created by 서동환 on 6/10/25.
//

import UIKit

final class DayOfTheWeekHStackView: UIStackView {
    
    // MARK: - Properties
    
    private let dayOfTheWeekList = ["일", "월", "화", "수", "목", "금", "토"]
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

private extension DayOfTheWeekHStackView {
    func configure() {
        setHierarchy()
        setStyles()
    }
    
    func setStyles() {
        self.axis = .horizontal
        self.distribution = .fillEqually
    }
    
    func setHierarchy() {
        for (index, day) in dayOfTheWeekList.enumerated() {
            let dayLabel = UILabel().then {
                $0.text = day
                if index == 0 {
                    $0.textColor = .sundayText
                } else if index == 6 {
                    $0.textColor = .saturdayText
                } else {
                    $0.textColor = .gray900
                }
                $0.font = .bodyMedium(12)
                $0.textAlignment = .center
            }
            
            self.addArrangedSubview(dayLabel)
        }
    }
}
