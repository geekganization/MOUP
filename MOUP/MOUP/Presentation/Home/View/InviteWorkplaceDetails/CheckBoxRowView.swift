//
//  CheckBoxRowView.swift
//  MOUP
//
//  Created by shinyoungkim on 7/5/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class CheckBoxRowView: UIView {
    
    // MARK: - Properties
    
    let checkBoxButtonDidTap = PublishSubject<Bool>()
    
    var isChecked: Bool = false {
        didSet {
            checkBoxButton.isSelected = isChecked
        }
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let infoIcon = UIImageView().then {
        $0.image = UIImage.infoIcon
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let checkBoxButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage.checkboxUnselected
        config.baseBackgroundColor = .clear
        $0.configuration = config
        
        $0.configurationUpdateHandler = { button in
            var config = button.configuration
            config?.image = button.isSelected ? UIImage.checkboxSelected : UIImage.checkboxUnselected
            button.configuration = config
        }
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    init(title: String, showInfoIcon: Bool = false, isLast: Bool = false) {
        titleLabel.text = title
        infoIcon.isHidden = !showInfoIcon
        separatorView.isHidden = isLast
        
        super.init(frame: .zero)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setChecked(_ checked: Bool) {
        guard isChecked != checked else { return }
        isChecked = checked
        checkBoxButtonDidTap.onNext(isChecked)
    }
}

private extension CheckBoxRowView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            titleLabel,
            infoIcon,
            checkBoxButton,
            separatorView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        infoIcon.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
        
        checkBoxButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        separatorView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        checkBoxButton.rx.tap
            .bind { [weak self] in
                self?.toggle()
            }
            .disposed(by: disposeBag)
    }
    
    func toggle() {
        isChecked.toggle()
        checkBoxButtonDidTap.onNext(isChecked)
    }
}
