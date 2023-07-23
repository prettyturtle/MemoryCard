//
//  SignUpViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/25.
//

import UIKit
import SnapKit
import Then
import Toast
import FirebaseAuth

// MARK: - 회원가입 뷰컨
final class SignUpViewController: UIViewController {
    
    // MARK: ========================= < UI 컴포넌트 > =========================
    
    /// 스크롤뷰
    private lazy var scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(didTapScrollView))
        $0.addGestureRecognizer(tapGesture)
        $0.isUserInteractionEnabled = true
    }
    
    /// 스크롤뷰 컨텐츠뷰
    private lazy var contentView = UIView()
    
    /// 이름 라벨
    private lazy var nameLabel = UILabel().then {
        $0.text = "이름"
        $0.font = .systemFont(ofSize: 18.0, weight: .medium)
    }
    
    /// 이름 입력 텍스트 필드
    private lazy var nameTextField = UITextField().then {
        $0.placeholder = "이름을 입력하세요..."      // 텍스트 필드 placeholder
        $0.keyboardType = .default              // 키보드 타입 : 이메일
        $0.borderStyle = .roundedRect           // 테두리 타입
        $0.offAutoChange(true)                  // 오토 대문자, 오토 수정 off
    }
    
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
        $0.textContentType = .oneTimeCode
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
        $0.textContentType = .oneTimeCode
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
        setKeyboardObserver()                       // 키보드 옵저버
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
    
    /// 스크롤 뷰를 탭 했을 때
    @objc func didTapScrollView() {
        view.endEditing(true) // 키보드 내리기
    }
    
    /// 키보드가 올라올 때
    /// - Parameter notification: 노티피케이션
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }
        
        scrollView.contentInset.bottom = keyboardFrame.size.height + 48.0
        
        let firstResponder = view.subviews.filter { $0.isFirstResponder }.first as? UITextField
        
        UIView.animate(withDuration: 0.4) {
            self.scrollView.scrollRectToVisible(firstResponder?.frame ?? CGRect.zero, animated: true)
        }
    }
    
    /// 키보드가 내려갈 때
    /// - Parameter notification: 노티피케이션
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    /// 키보드 옵저버 Add
    func setKeyboardObserver() {
         NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
         )
         
         NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object:nil
         )
     }
    
    /// 회원가입 버튼을 눌렀을 때
    /// - Parameter sender: 회원가입 버튼
    @objc func didTapSignUpButton(_ sender: UIButton) {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let rePassword = rePasswordTextField.text else {              // 이름, 이메일, 비밀번호, 비밀번호 재입력 옵셔널 해제
            return                                                          // 이름, 이메일, 비밀번호, 비밀번호 재입력이 nil일 때
        }
        
        if name.isEmpty {                                                   // 이름이 빈 문자열일 때
            view.makeToast("이름을 입력해주세요!")                               // 토스트 얼럿 노출 -> 리턴
            return
        } else if email.isEmpty {                                           // 이메일이 빈 문자열일 때
            view.makeToast("이메일을 입력해주세요!")                              // 토스트 얼럿 노출 -> 리턴
            return
        } else if password.isEmpty {                                        // 비밀번호가 빈 문자열일 때
            view.makeToast("비밀번호를 입력해주세요!")                             // 토스트 얼럿 노출 -> 리턴
            return
        } else if rePassword.isEmpty {                                      // 비밀번호 재입력이 빈 문자열일 때
            view.makeToast("모두 입력해주세요!")                                 // 토스트 얼럿 노출 -> 리턴
            return
        }
        
        if password != rePassword {                                         // 비밀번호와 비밀번호 재입력이 다르면
            view.makeToast("비밀번호를 확인해주세요!")                             // 토스트 얼럿 노출 -> 리턴
            return
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
                
                let id = authResult.user.uid
                let createdDate = authResult.user.metadata.creationDate
                let lastSignInDate = authResult.user.metadata.lastSignInDate
                
                let user = User(
                    id: id,
                    email: email,
                    name: name,
                    createdDate: createdDate,
                    lastSignInDate: lastSignInDate
                )
                
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
                self.view.makeToast("다시 시도해주세요!")                        // 토스트 얼럿 노출
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
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        [
            nameLabel,
            nameTextField,
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
            contentView.addSubview($0)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalToSuperview().inset(Constant.defaultInset)
        }
        nameTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(nameLabel.snp.bottom).offset(Constant.defaultInset / 2)
            $0.height.equalTo(48.0)
        }
        emailLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(nameTextField.snp.bottom).offset(Constant.defaultInset)
        }
        emailTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(emailLabel.snp.bottom).offset(Constant.defaultInset / 2)
            $0.height.equalTo(48.0)
        }
        emailErrorLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(emailTextField.snp.bottom).offset(Constant.defaultInset / 4)
        }
        passwordLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(emailErrorLabel.snp.bottom).offset(Constant.defaultInset)
        }
        passwordTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(passwordLabel.snp.bottom).offset(Constant.defaultInset / 2)
            $0.height.equalTo(48.0)
        }
        passwordErrorLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(Constant.defaultInset / 4)
        }
        rePasswordLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(passwordErrorLabel.snp.bottom).offset(Constant.defaultInset)
        }
        rePasswordTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(rePasswordLabel.snp.bottom).offset(Constant.defaultInset / 2)
            $0.height.equalTo(48.0)
        }
        rePasswordErrorLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(rePasswordTextField.snp.bottom).offset(Constant.defaultInset / 4)
        }
        signUpButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(rePasswordErrorLabel.snp.bottom).offset(Constant.defaultInset * 2)
            $0.height.equalTo(48.0)
            $0.bottom.equalToSuperview()
        }
    }
}
