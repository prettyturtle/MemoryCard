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

// MARK: - 회원가입 뷰컨
final class SignUpViewController: UIViewController {
    
    // MARK: ========================= < UI 컴포넌트 > =========================
    /// 이메일 입력 텍스트 필드
    private lazy var emailTextField = UITextField().then {
        $0.placeholder = "이메일을 입력하세요..."    // 텍스트 필드 placeholder
        $0.keyboardType = .emailAddress         // 키보드 타입 : 이메일
        $0.borderStyle = .roundedRect           // 테두리 타입
        $0.offAutoChange(true)                  // 오토 대문자, 오토 수정 off
    }
    
    /// 비밀번호 입력 텍스트 필드
    private lazy var passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호를 입력하세요..."   // 텍스트 필드 placeholder
        $0.borderStyle = .roundedRect           // 테두리 타입
        $0.isSecureTextEntry = true             // 비밀번호 가리기
        $0.offAutoChange(true)                  // 오토 대문자, 오토 수정 off
    }
    
    /// 회원가입 버튼
    private lazy var signUpButton = OpacityButton().then {
        $0.setTitle("회원가입", for: .normal)                        // 버튼 타이틀 설정
        $0.style = .fill(backgroundColor: .systemOrange)          // 버튼 스타일 : 배경색 systemOrange
        $0.addTarget(                                             // 버튼을 눌렀을 때 이벤트 등록
            self,
            action: #selector(didTapSignUpButton),
            for: .touchUpInside
        )
    }
    // MARK: ========================= </ UI 컴포넌트 > =========================
}

// MARK: - 라이프 사이클
extension SignUpViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground    // 배경색 설정
        setupNavigationBar()                        // 내비게이션 설정
        setupLayout()                               // 레이아웃 설정
    }
}

// MARK: - UI 이벤트
private extension SignUpViewController {
    
    /// 회원가입 버튼을 눌렀을 때
    /// - Parameter sender: 회원가입 버튼
    @objc func didTapSignUpButton(_ sender: UIButton) {
        IndicatorManager.shared.start()                                     // 로딩 인디케이터 시작
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {                  // 이메일, 비밀번호 옵셔널 해제
            return                                                          // 이메일, 비밀번호가 nil일 때
        }
        
        guard !email.isEmpty, !password.isEmpty else {                      // 이메일, 비밀번호가 공백이 아닌지 확인
                                                                            // TODO: - 이메일, 비밀번호가 공백일 때 처리
            return                                                          // 이메일, 비밀번호가 공백일 때
        }
        
        let userInput = (email, password)                                   // 유저가 입력한 이메일, 비밀번호
        
        // 파이어베이스 이메일 회원가입 시작
        AuthManager.shared.signUp(userInput) { [weak self] result in
            IndicatorManager.shared.stop()                                  // 로딩 인디케이터 제거
            
            guard let self = self else { return }
            
            switch result {
            case .success(let authResult):                                  // 회원가입 성공 (`회원가입 결과`)
                print("🎉 이메일 회원가입 성공", authResult)
                
                let rootVC = TabBarController()                             // 메인 탭바 컨트롤러
                self.changeRootVC(rootVC, animated: true)                   // 메인 탭바 컨트롤러로 루트 뷰컨 변경
                
            case .failure(let error):                                       // 회원가입 실패 (`에러`)
                                                                            // TODO: - 회원가입 실패 처리
                print("🎉 이메일 회원가입 실패", error)
            }
        }
    }
}

// MARK: - UI 레이아웃
private extension SignUpViewController {
    
    /// 내비게이션 바 설정
    func setupNavigationBar() {
        navigationItem.title = "회원가입"
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    /// 레이아읏 설정
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
