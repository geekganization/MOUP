//
//  SceneDelegate.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit
import OSLog
import FirebaseAuth
import GoogleSignIn

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            do {
                try Auth.auth().signOut()
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            } catch {
                logger.error("앱 첫 실행 시 로그아웃 실패: \(error.localizedDescription)")
            }
        } else {
            logger.debug("앱 재실행: 로그아웃 생략")
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let rootVC: UIViewController
        
        if let currentUser = Auth.auth().currentUser {
            // 로그인된 상태 → 메인(TabBar)으로
            rootVC = TabBarViewController(viewModel: TabBarViewModel())
            
            //            let notificationService = DummyNotificationService()
            //            notificationService.runNotificationPipeline(uid: currentUser.uid)
        } else {
            // 로그인 안 됨 → 로그인 화면
            let loginVC = LoginViewController(
                viewModel: LoginViewModel(
                    appleAuthService: AppleAuthService(),
                    googleAuthService: GoogleAuthService(),
                    userService: UserService()
                )
            )
            rootVC = UINavigationController(rootViewController: loginVC)
        }
        
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}
