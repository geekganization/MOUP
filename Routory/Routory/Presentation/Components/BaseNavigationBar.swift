//
//  BaseNavigationBar.swift
//  Routory
//
//  Created by 송규섭 on 6/16/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class BaseNavigationBar: UIView {

    // MARK: - Properties

    private let title: String

    // MARK: - UI Components

    fileprivate let backButton = UIButton().then {
        $0.setImage(UIImage.chevronLeft, for: .normal)
        $0.contentHorizontalAlignment = .right
    }

    fileprivate let rightButton = UIButton()

    fileprivate let titleLabel = UILabel().then {
        $0.font = .headBold(20)
        $0.setLineSpacing(.headBold)
        $0.textColor = UIColor.gray900
    }

    // MARK: - Public Method

    func configureBackButton(isHidden: Bool = false) {
        backButton.isHidden = isHidden // 뒤로 가기 버튼을 띄우고 싶지 않은 경우
    }

    func configureRightButton(icon: UIImage?, title: String?) {
        rightButton.setImage(icon, for: .normal)
        rightButton.contentHorizontalAlignment = .left

        if let title = title, title.count <= 2 {
            rightButton.setAttributedTitle(NSAttributedString(string: title, attributes: [.font: UIFont.headBold(14), .foregroundColor: UIColor.gray900]), for: .normal)
            rightButton.setAttributedTitle(NSAttributedString(string: title, attributes: [.font: UIFont.headBold(14), .foregroundColor: UIColor.gray900]), for: .selected)
        }
    }

    func configureTitle(title: String) {
        titleLabel.text = title
    }

    // MARK: - Initializer

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 50)
    }
}

private extension BaseNavigationBar {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            backButton,
            titleLabel,
            rightButton
        )
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .systemBackground
        titleLabel.text = title
    }

    // MARK: - setConstraints
    func setConstraints() {
        self.snp.makeConstraints {
            $0.height.equalTo(50)
        }

        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.greaterThanOrEqualTo(40)
            $0.height.equalToSuperview()
        }
        
        backButton.imageView?.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }

        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(32)
            $0.height.equalToSuperview()
        }
        
        rightButton.imageView?.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
    }
}

extension Reactive where Base: BaseNavigationBar {
    var backBtnTapped: ControlEvent<Void> {
        return base.backButton.rx.tap
    }

    var rightBtnTapped: ControlEvent<Void> {
        return base.rightButton.rx.tap
    }
}
