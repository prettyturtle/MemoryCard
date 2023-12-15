//
//  SceneDelegate.swift
//  MemoryCard
//
//  Created by yc on 2023/03/25.
//

import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      var handled: Bool
        
      handled = GIDSignIn.sharedInstance.handle(url)
        
      if handled {
          return true
      }
        
      return false
    }
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .systemBackground
        window?.tintColor = .systemOrange
        
        var rootViewController: UIViewController
        
        let feedback = GameQuizCardZip(
            id: "",
            originID: "", 
            cards: (0..<10).map {
                GameQuizCardZip.GameQuizCard(
                    target: "target\($0)",
                    answer: "answer\($0)",
                    id: $0,
                    originID: $0,
                    sunjis: ["sunji\($0)"],
                    isFront: true,
                    isCorrect: $0 % 2 == 0
                )
            },
            mIdx: ""
        )
        rootViewController = GameFeedbackViewController(feedback: feedback)
        
        if let currentUser = AuthManager.shared.getCurrentUser() {
            
            let id = currentUser.id
            
            DBManager.shared.fetchDocument(.user, documentName: id, type: User.self) { result in
                if case var .success(fetchedUser) = result {
                    fetchedUser.lastSignInDate = Date.now
                    fetchedUser.pushToken = Constant.pushToken
                    
                    DBManager.shared.save(.user, documentName: id, data: fetchedUser) { _ in}
                }
            }
            
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
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
