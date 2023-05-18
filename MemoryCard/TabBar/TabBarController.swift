//
//  TabBarController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SwiftUI

final class TabBarController: UITabBarController {
    
    private let homeVC = UINavigationController(rootViewController: MyCardListViewController())
    private let createCardTempVC = UIViewController()
    private let myInfoVC = UIHostingController(rootView: MyInfoView())
    
    private lazy var homeVCTabBarItem = UITabBarItem(
        title: "카드리스트",
        image: UIImage(systemName: "list.bullet"),
        selectedImage: nil
    ).then { $0.tag = 0 }
    
    private lazy var createCardVCTabBarItem = UITabBarItem(
        title: "카드만들기",
        image: UIImage(systemName: "plus.circle"),
        selectedImage: nil
    ).then { $0.tag = 1 }
    
    private lazy var myInfoVCTabBarItem = UITabBarItem(
        title: "설정",
        image: UIImage(systemName: "gearshape"),
        selectedImage: nil
    ).then { $0.tag = 2 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarItem()
        
        tabBar.backgroundColor = .secondarySystemBackground
        
        viewControllers = [
            homeVC,
            createCardTempVC,
            myInfoVC
        ]
        
        delegate = self
    }
    
    private func setupTabBarItem() {
        homeVC.tabBarItem = homeVCTabBarItem
        createCardTempVC.tabBarItem = createCardVCTabBarItem
        myInfoVC.tabBarItem = myInfoVCTabBarItem
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        if tabBarController.tabBar.selectedItem?.tag == 1 {
            
            let createCardVC = UINavigationController(rootViewController: CreateCardIntroViewController())
            
            createCardVC.modalPresentationStyle = .fullScreen
            present(createCardVC, animated: true)
            
            return false
        } else {
            return true
        }
    }
}
