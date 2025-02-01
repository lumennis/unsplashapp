//
//  SceneDelegate.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import UIKit

@available(iOS 13.0, *)
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let launchScreen = LaunchScreenViewController()
        window.rootViewController = launchScreen
        window.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setupApp()
        }
    }
    
    private func setupApp() {
        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        
        let networkManager = NetworkManager()
        appCoordinator = AppCoordinator(navigationController: navigationController, networkManager: networkManager)
        appCoordinator?.start()
        
        UIView.transition(
            with: window!,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        appCoordinator = nil
    }
}

