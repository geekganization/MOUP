//
//  TotalCardInfoView.swift
//  Routory
//
//  Created by 송규섭 on 6/29/25.
//

import UIKit

class HeaderCardView: CardView {

    private let cardViewType: CardViewType
    private var gradientLayer: CAGradientLayer?

    enum CardViewType {
        case total(startColor: CGColor, endColor: CGColor)
        case routine(backgroundColor: UIColor)
    }

    init(cardViewType: CardViewType) {
        self.cardViewType = cardViewType
        super.init(frame: .zero)

        setAdditionalDetail()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }

    private func setAdditionalDetail() {
        switch self.cardViewType {
        case .total(let startColor, let endColor):
            setTotalCardType(startColor: startColor, endColor: endColor)

            let logoImageView = UIImageView().then {
                $0.image = .defaultLogo
                $0.alpha = 0.14
                $0.contentMode = .scaleAspectFit
            }
            addSubview(logoImageView)
            // TODO: - 제약조건 추가

        case .routine(let background):
            backgroundColor = background
        }
    }

    private func setTotalCardType(startColor: CGColor, endColor: CGColor) {
        backgroundColor = .clear
        let gradient = CAGradientLayer()
        gradient.colors = [startColor, endColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.cornerRadius = 12
        gradient.masksToBounds = true
        layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient
    }

}
