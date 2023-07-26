//
//  LoginView.swift
//  MemoryCard
//
//  Created by yc on 2023/07/27.
//

import SwiftUI
import Toast

struct LoginView: UIViewControllerRepresentable {
    
    @Binding var isShowLoginView: Bool
    @Binding var isSuccessLogin: Bool
    
    private func didSuccessLogin() {
        isSuccessLogin = true
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let loginVC = LoginViewController()
        
        loginVC.isRevokeLogin = true
        loginVC.isRevokeLoginCompletion = didSuccessLogin
        
        let loginNC = UINavigationController(rootViewController: loginVC)
        return loginNC
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        if isShowLoginView {
            if let loginVC = uiViewController.viewControllers.first as? LoginViewController {
                loginVC.view.makeToast("탈퇴 전 로그인을 해주세요!")
            }
        }
    }
}
