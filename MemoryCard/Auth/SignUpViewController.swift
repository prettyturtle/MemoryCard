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
    /// 이메일 라벨
    private lazy var emailLabel = UILabel().then {
        $0.text = "이메일"
        $0.font = .systemFont(ofSize: 18.0, weight: .medium)
    }
    
    /// 이메일 에러 라벨
    private lazy var emailErrorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14.0, weight: .regular)
        $0.textColor = .systemRed
    }
    
    /// 이메일 입력 텍스트 필드
    private lazy var emailTextField = UITextField().then {
        $0.placeholder = "이메일을 입력하세요..."    // 텍스트 필드 placeholder
        $0.keyboardType = .emailAddress         // 키보드 타입 : 이메일
        $0.borderStyle = .roundedRect           // 테두리 타입
        $0.offAutoChange(true)                  // 오토 대문자, 오토 수정 off
    }
    
    /// 비밀번호 라벨
    private lazy var passwordLabel = UILabel().then {
        $0.text = "비밀번호"
        $0.font = .systemFont(ofSize: 18.0, weight: .medium)
    }
    
    /// 비밀번호 입력 텍스트 필드
    private lazy var passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호를 입력하세요..."   // 텍스트 필드 placeholder
        $0.borderStyle = .roundedRect           // 테두리 타입
        $0.isSecureTextEntry = true             // 비밀번호 가리기
        $0.delegate = self                      // 델리게이트 self
        $0.offAutoChange(true)                  // 오토 대문자, 오토 수정 off
    }
    
    /// 비밀번호 에러 라벨
    private lazy var passwordErrorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14.0, weight: .regular)
        $0.textColor = .systemRed
    }
    
    /// 비밀번호 재입력 텍스트 필드
    private lazy var rePasswordTextField = UITextField().then {
        $0.placeholder = "비밀번호를 다시 입력하세요..."   // 텍스트 필드 placeholder
        $0.borderStyle = .roundedRect           // 테두리 타입
        $0.isSecureTextEntry = true             // 비밀번호 가리기
        $0.delegate = self                      // 델리게이트 self
        $0.offAutoChange(true)                  // 오토 대문자, 오토 수정 off
    }
    
    /// 비밀번호 재확인 라벨
    private lazy var rePasswordLabel = UILabel().then {
        $0.text = "비밀번호 재확인"
        $0.font = .systemFont(ofSize: 18.0, weight: .medium)
    }
    
    /// 비밀번호 재확인 에러 라벨
    private lazy var rePasswordErrorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14.0, weight: .regular)
        $0.textColor = .systemRed
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

// MARK: - 로직
extension SignUpViewController {
    
    /// 비밀번호 입력, 재입력 시 둘이 같은지 확인하는 함수
    ///
    /// 둘이 같지 않으면 `rePasswordErrorLabel`에 "비밀번호가 다릅니다"가 나온다
    ///
    /// - Parameters:
    ///   - focused: 현재 포커싱된 텍스트 필드
    ///   - other: 포커싱 되지 않은 텍스트 필드
    func checkEqualPassword(_ focused: UITextField, other: UITextField) {
        guard focused.text != "",
              other.text != "" else {       // 포커싱된 텍스트 필드와 포커싱되지 않은 텍스트 필드의 텍스트가 존재하는지
            rePasswordErrorLabel.text = ""  // 둘 중에 하나라도 텍스트가 비어있다면 에러 메시지는 보여주지 않는다
            return
        }
        
        if focused.text == other.text {
            rePasswordErrorLabel.text = ""                  // 서로 같으면 에러메시지 안보여준다
        } else {
            rePasswordErrorLabel.text = "비밀번호가 다릅니다"    // 서로 다르면 "비밀번호가 다릅니다" 에러 메시지 노출
        }
    }
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case passwordTextField:
            checkEqualPassword(textField, other: rePasswordTextField)   // 비밀번호 같은지 체크
        case rePasswordTextField:
            checkEqualPassword(textField, other: passwordTextField)     // 비밀번호 같은지 체크
        default:
            break
        }
    }
}

// MARK: - UI 이벤트
private extension SignUpViewController {
    
    /// 회원가입 버튼을 눌렀을 때
    /// - Parameter sender: 회원가입 버튼
    @objc func didTapSignUpButton(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {                  // 이메일, 비밀번호 옵셔널 해제
            return                                                          // 이메일, 비밀번호가 nil일 때
        }
        
        guard !email.isEmpty, !password.isEmpty else {                      // 이메일, 비밀번호가 공백이 아닌지 확인
                                                                            // TODO: - 이메일, 비밀번호가 공백일 때 처리
            return                                                          // 이메일, 비밀번호가 공백일 때
        }
        
        IndicatorManager.shared.start()                                     // 로딩 인디케이터 시작
        
        let userInput = (email, password)                                   // 유저가 입력한 이메일, 비밀번호
        
        // 파이어베이스 이메일 회원가입 시작
        AuthManager.shared.signUp(userInput) { [weak self] result in
            IndicatorManager.shared.stop()                                  // 로딩 인디케이터 제거
            
            guard let self = self else { return }
            
            switch result {
            case .success(let authResult):                                  // 회원가입 성공 (`회원가입 결과`)
                print("🎉 이메일 회원가입 성공", authResult)
                
                let user = User(id: authResult.user.uid, email: email)
                
                // 유저 정보 저장 시작
                DBManager.shared.save(.user, documentName: user.id, data: user) { dbResult in
                    switch dbResult {
                    case .success(_):                                               // 유저 저장 성공
                        let rootVC = TabBarController()                             // 메인 탭바 컨트롤러
                        self.changeRootVC(rootVC, animated: true)                   // 메인 탭바 컨트롤러로 루트 뷰컨 변경
                    case .failure(let error):
                                                                                    // TODO: - 유저 저장 실패 처리
                        print("🎉 유저 저장 실패", error)
                    }
                }
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
            emailLabel,
            emailTextField,
            emailErrorLabel,
            passwordLabel,
            passwordTextField,
            passwordErrorLabel,
            rePasswordLabel,
            rePasswordTextField,
            rePasswordErrorLabel,
            signUpButton
        ].forEach {
            view.addSubview($0)
        }
        
        emailLabel.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset * 2)
        }
        emailTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(emailLabel.snp.bottom).offset(Constant.defaultInset / 2)
            $0.height.equalTo(48.0)
        }
        emailErrorLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(emailTextField.snp.bottom).offset(Constant.defaultInset / 4)
        }
        passwordLabel.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(emailErrorLabel.snp.bottom).offset(Constant.defaultInset * 2)
        }
        passwordTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(passwordLabel.snp.bottom).offset(Constant.defaultInset / 2)
            $0.height.equalTo(48.0)
        }
        passwordErrorLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(Constant.defaultInset / 4)
        }
        rePasswordLabel.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(passwordErrorLabel.snp.bottom).offset(Constant.defaultInset * 2)
        }
        rePasswordTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(rePasswordLabel.snp.bottom).offset(Constant.defaultInset / 2)
            $0.height.equalTo(48.0)
        }
        rePasswordErrorLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(rePasswordTextField.snp.bottom).offset(Constant.defaultInset / 4)
        }
        signUpButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(rePasswordErrorLabel.snp.bottom).offset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
    }
}
