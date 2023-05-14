//
//  UIViewController+.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit

extension UIViewController {
    func changeRootVC(_ to: UIViewController, animated: Bool) {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.changeRootViewController(to, animated: true)
    }
}
