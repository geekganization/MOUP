//
//  LoadingManager.swift
//  Routory
//
//  Created by 송규섭 on 6/19/25.
//


import UIKit

final class LoadingManager {
    static let shared = LoadingManager()
    private var loadingView: LoadingAnimationView?
    
    private init() {}
    
    // MARK: - Public Methods
    static func start() {
        DispatchQueue.main.async {
            shared.show()
        }
    }
    
    static func stop() {
        DispatchQueue.main.async {
            shared.hide()
        }
    }
    
    // MARK: - Private Methods
    private func show() {
        // 이미 표시중이면 무시
        guard loadingView == nil else { return }
        
        // 키 윈도우 찾기
        guard let window = getKeyWindow() else { return }
        
        // 로딩 뷰 생성 및 추가
        let loading = LoadingAnimationView()
        loading.frame = window.bounds
        loading.tag = 999999 // 고유 태그로 중복 방지
        
        window.addSubview(loading)
        loading.startAnimation()
        
        self.loadingView = loading
    }
    
    private func hide() {
        guard let loading = loadingView else { return }
        
        loading.stopAnimation()
        self.loadingView = nil
    }
    
    private func getKeyWindow() -> UIWindow? {
        // iOS 13+ 대응
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}