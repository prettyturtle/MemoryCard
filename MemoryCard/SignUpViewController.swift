//
//  SignUpViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/25.
//

import UIKit
import SnapKit
import Then
import FirebaseAuth

final class SignUpViewController: UIViewController {
    private lazy var emailTextField = UITextField().then {
        $0.offAutoChange(true)
        $0.keyboardType = .emailAddress
        $0.borderStyle = .roundedRect
        $0.placeholder = "이메일을 입력하세요..."
    }
    private lazy var passwordTextField = UITextField().then {
        $0.offAutoChange(true)
        $0.borderStyle = .roundedRect
        $0.placeholder = "비밀번호를 입력하세요..."
        $0.keyboardType = .default
        $0.isSecureTextEntry = true
    }
    private lazy var signUpButton = OpacityButton().then {
        $0.style = .fill(backgroundColor: .systemGreen)
        $0.setTitle("회원가입", for: .normal)
        $0.addTarget(
            self,
            action: #selector(didTapSignUpButton),
            for: .touchUpInside
        )
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupLayout()
    }
}

private extension SignUpViewController {
    @objc func didTapSignUpButton(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        
        AuthManager.shared.signUp((email, password)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let authResult):
                print("🎉 이메일 회원가입 성공", authResult)
                
                let rootVC = TabBarController()
                self.changeRootVC(rootVC, animated: true)
            case .failure(let error):
                print("🎉 이메일 회원가입 실패", error)
            }
        }
    }
}

private extension SignUpViewController {
    func setupNavigationBar() {
        navigationItem.title = "회원가입"
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    func setupLayout() {
        [
            emailTextField,
            passwordTextField,
            signUpButton
        ].forEach {
            view.addSubview($0)
        }
        
        emailTextField.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
        passwordTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(emailTextField.snp.bottom).offset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
        signUpButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
    }
}
