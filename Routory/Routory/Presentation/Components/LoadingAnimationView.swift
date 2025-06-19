//
//  LoadingAnimationView.swift
//  Routory
//
//  Created by 송규섭 on 6/19/25.
//


import UIKit
import SnapKit
import Then

final class LoadingAnimationView: UIView {
    
    // MARK: - UI Components
    private let overlayView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    private let logoImageView = UIImageView().then {
        $0.image = .textLogo
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func startAnimation() {
        // 초기 상태 설정
        alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // 페이드인 + 스케일 애니메이션
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.logoImageView.transform = .identity
        }
        
        // 변속 회전 애니메이션 시작
        startRotation()
    }
    
    func stopAnimation() {
        // 애니메이션 정지
        logoImageView.layer.removeAllAnimations()
        
        // 페이드아웃
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.alpha = 0
            self.logoImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    private func setupUI() {
        addSubview(overlayView)
        overlayView.addSubview(logoImageView)
        
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(42)
        }
    }
    
    private func startRotation() {
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        
        rotationAnimation.values = [
            0,
            CGFloat.pi * 2,
            CGFloat.pi * 4,
            CGFloat.pi * 6,
            CGFloat.pi * 8
        ]
        
        rotationAnimation.keyTimes = [0, 0.2, 0.4, 0.7, 1.0]
        rotationAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .linear),
            CAMediaTimingFunction(name: .easeIn),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        
        rotationAnimation.duration = 3.0
        rotationAnimation.repeatCount = .infinity
        
        logoImageView.layer.add(rotationAnimation, forKey: "rotation")
    }
}