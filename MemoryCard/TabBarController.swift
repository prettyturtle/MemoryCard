//
//  TabBarController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit

final class TabBarController: UITabBarController {
    
    private let homeVC = UINavigationController(rootViewController: HomeViewController())
    private let myInfoVC = UINavigationController(rootViewController: MyInfoViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarItem()
        
        viewControllers = [
            homeVC,
            myInfoVC
        ]
    }
    
    private func setupTabBarItem() {
        homeVC.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        myInfoVC.tabBarItem = UITabBarItem(
            title: "내정보",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
    }
}
