//
//  SectionHeaderView.swift
//  Routory
//
//  Created by shinyoungkim on 6/28/25.
//

import UIKit
import Then
import SnapKit

final class SectionHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    
    static let identifier = "SectionHeaderView"
    
    // MARK: - UI Components

    private let titleLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.numberOfLines = 1
    }
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods

    func setTitle(_ title: String, highlightAsterisk: Bool = false) {
        if highlightAsterisk {
            let fullText = "\(title) *"
            let attributed = NSMutableAttributedString(string: fullText)
            attributed.addAttributes([
                .font: UIFont.headBold(18),
                .foregroundColor: UIColor.gray900
            ], range: NSRange(location: 0, length: fullText.count))

            if let range = fullText.range(of: "*") {
                attributed.addAttribute(
                    .foregroundColor,
                    value: UIColor.primary500,
                    range: NSRange(range, in: fullText)
                )
            }
            titleLabel.attributedText = attributed
        } else {
            titleLabel.text = title
        }
    }
}
