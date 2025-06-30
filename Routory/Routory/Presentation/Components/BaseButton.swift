//
//  BaseButton.swift
//  Routory
//
//  Created by 서동환 on 6/30/25.
//

import UIKit

final class BaseButton: UIButton {
    
    // MARK: - Initializer
    
    init(title: String, isSecondary: Bool = false) {
        super.init(frame: .zero)
        configure(title: title, isSecondary: isSecondary)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

// MARK: - UI Methods

private extension BaseButton {
    func configure(title: String, isSecondary: Bool) {
        setStyles(title: title, isSecondary: isSecondary)
    }
    
    func setStyles(title: String, isSecondary: Bool) {
        var config = UIButton.Configuration.filled()
        
        let normalAttribute = AttributeContainer([.font: UIFont.buttonSemibold(18),
                                                  .foregroundColor: isSecondary ? UIColor.gray600 : UIColor.white])
        let disableAttribute = AttributeContainer([.font: UIFont.buttonSemibold(18),
                                                   .foregroundColor: UIColor.gray500])
        config.attributedTitle = AttributedString(title, attributes: normalAttribute)
        
        let handler: UIButton.ConfigurationUpdateHandler = { button in
            switch button.state {
            case .normal:
                button.configuration?.attributedTitle = AttributedString(title, attributes: normalAttribute)
                button.configuration?.baseBackgroundColor = isSecondary ? .gray200 : .accent
            case .disabled:
                button.configuration?.attributedTitle = AttributedString(title, attributes: disableAttribute)
                button.configuration?.baseBackgroundColor = .gray300
            case .highlighted:
                button.configuration?.attributedTitle = AttributedString(title, attributes: normalAttribute)
                button.configuration?.baseBackgroundColor = isSecondary ? .gray200 : .accent
            default:
                button.configuration?.attributedTitle = AttributedString(title, attributes: normalAttribute)
                button.configuration?.baseBackgroundColor = .accent
            }
        }
        
        self.configuration = config
        self.configurationUpdateHandler = handler
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
    }
}
