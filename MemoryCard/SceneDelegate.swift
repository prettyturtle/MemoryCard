//
//  SceneDelegate.swift
//  MemoryCard
//
//  Created by yc on 2023/03/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .systemBackground
        
        var rootViewController: UIViewController
        
        if let currentUser = AuthManager.shared.getCurrentUser() {
            rootViewController = TabBarController()
        } else {
            rootViewController = UINavigationController(rootViewController: LoginViewController())
        }
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool) {
        guard let window = window else { return }
        
        window.rootViewController = vc
        
        if animated {
            UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil)
        }
    }
}
