//
//  LoginViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/25.
//

import UIKit
import SnapKit
import Then
import FirebaseAuth

final class LoginViewController: UIViewController {
    
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
    private lazy var loginButton = OpacityButton().then {
        $0.style = .fill(backgroundColor: .systemOrange)
        $0.setTitle("로그인", for: .normal)
        $0.addTarget(
            self,
            action: #selector(didTapLoginButton),
            for: .touchUpInside
        )
    }
    private lazy var moveToSignUpButton = UIButton().then {
        $0.setTitleColor(.secondaryLabel, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .medium)
        $0.addTarget(
            self,
            action: #selector(didTapMoveToSignUpButton),
            for: .touchUpInside
        )
        
        let text = "아직 계정이 없으신가요? 회원가입"
        let attributedText = NSMutableAttributedString(string: text)
        let attributedRange = (text as NSString).range(of: "회원가입")
        
        attributedText.addAttribute(.foregroundColor, value: UIColor.systemMint, range: attributedRange)
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16.0, weight: .semibold), range: attributedRange)
        $0.setAttributedTitle(attributedText, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
    }
}

private extension LoginViewController {
    @objc func didTapMoveToSignUpButton(_ sender: UIButton) {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func didTapLoginButton(_ sender: UIButton) {
        IndicatorManager.shared.start()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        
        AuthManager.shared.login((email, password)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let authResult):
                IndicatorManager.shared.stop()
                print("🎉 이메일 로그인 성공", authResult)
                
                let rootVC = TabBarController()
                self.changeRootVC(rootVC, animated: true)
            case .failure(let error):
                print("🎉 이메일 로그인 실패", error)
            }
        }
    }
}

private extension LoginViewController {
    func setupNavigationBar() {
        navigationItem.title = "로그인"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    func setupLayout() {
        [
            emailTextField,
            passwordTextField,
            loginButton,
            moveToSignUpButton
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
        loginButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
        moveToSignUpButton.snp.makeConstraints {
            $0.centerX.equalTo(loginButton.snp.centerX)
            $0.top.equalTo(loginButton.snp.bottom).offset(Constant.defaultInset)
        }
    }
}
