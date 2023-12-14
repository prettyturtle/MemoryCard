//
//  LoginViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/25.
//

import UIKit
import SwiftUI
import AuthenticationServices
import CryptoKit
import SnapKit
import Then
import Toast
import FirebaseAuth

// MARK: - 로그인 뷰컨
final class LoginViewController: UIViewController {
    
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
    
    /// 로그인 버튼
    private lazy var loginButton = OpacityButton().then {
        $0.setTitle("로그인", for: .normal)                        // 버튼 타이틀 설정
        $0.style = .fill(backgroundColor: .systemOrange)         // 버튼 스타일 : 배경색 systemOrange
        $0.addTarget(                                            // 버튼을 눌렀을 때 이벤트 등록
            self,
            action: #selector(didTapLoginButton),
            for: .touchUpInside
        )
    }
    
    // 라인 디바이더
    private let lineSeparatorRootView = UIHostingController(rootView: LineSeparator())
    private lazy var lineSeparator = lineSeparatorRootView.view ?? UIView()
    
    // 애플 로그인 버튼
    private lazy var appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black).then {
        $0.cornerRadius = 12.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAppleLogInButton))
        $0.addGestureRecognizer(tapGesture)
    }
    
    /// 회원가입 뷰컨 이동 버튼
    private lazy var moveToSignUpButton = UIButton().then {
        $0.setTitleColor(.secondaryLabel, for: .normal)                     // 텍스트 색상 설정
        $0.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .medium)    // 폰트 설정
        $0.addTarget(                                                       // 버튼을 눌렀을 때 이벤트 등록
            self,
            action: #selector(didTapMoveToSignUpButton),
            for: .touchUpInside
        )
        
        let text = "아직 계정이 없으신가요? 회원가입"                            // 버튼 타이틀
        let attrText = NSMutableAttributedString(string: text)           // 꾸며질 텍스트
        let attrRange = (text as NSString).range(of: "회원가입")           // 꾸며질 텍스트 범위 ("회원가입")
        
        attrText.addAttribute(                                          // "회원가입"만 색상 따로 설정
            .foregroundColor,
            value: UIColor.systemMint,
            range: attrRange
        )
        attrText.addAttribute(                                          // "회원가입"만 폰트 따로 설정
            .font,
            value: UIFont.systemFont(
                ofSize: 16.0,
                weight: .semibold
            ),
            range: attrRange
        )
        
        $0.setAttributedTitle(attrText, for: .normal)                   // 꾸며진 버튼 텍스트 설정
    }
    // MARK: ========================= </ UI 컴포넌트 > =========================
    
    // MARK: ========================= < 프로퍼티 > =========================
    
    var isRevokeLogin: Bool?                    // 탈퇴 전 로그인
    var isRevokeLoginCompletion: (() -> Void)?  // 탈퇴 전 로그인 후 이벤트
    
    var currentNonce: String?                   // 애플로그인 시 난수
    
    // MARK: ========================= </ 프로퍼티 > ========================
}

// MARK: - 라이프 사이클
extension LoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewWhenIsRevokeLogin()    // 탈퇴전 로그인 화면 예외처리
        setupNavigationBar()            // 내비게이션 설정
        setupLayout()                   // 레이아웃 설정
        
    }
}

// MARK: - UI 이벤트
private extension LoginViewController {
    
    /// 나가기 버튼 눌렀을 때
    @objc func didTapDismissButton() {
        dismiss(animated: true)
    }
    
    /// 스크롤 뷰를 탭 했을 때
    @objc func didTapScrollView() {
        view.endEditing(true)
    }
    
    /// 회원가입 뷰컨 이동 버튼을 눌렀을 때
    /// - Parameter sender: 회원가입 뷰턴 이동 버튼
    @objc func didTapMoveToSignUpButton(_ sender: UIButton) {
        let signUpVC = SignUpViewController()                               // 로그인 뷰컨
        navigationController?.pushViewController(signUpVC, animated: true)  // 로그인 뷰컨으로 이동
    }
    
    /// 로그인 버튼을 눌렀을 때
    /// - Parameter sender: 로그인 버튼
    @objc func didTapLoginButton(_ sender: UIButton) {
        guard var email = emailTextField.text,
              var password = passwordTextField.text else {                  // 이메일, 비밀번호 옵셔널 해제
            return                                                          // 이메일, 비밀번호가 nil일 때
        }
        
#if DEBUG
        if email == "1" && password == "1" {
            emailTextField.text = "test@test.com"
            passwordTextField.text = "121212"
            email = "test@test.com"
            password = "121212"
        }
#endif
        
        if email.isEmpty {                                                  // 이메일이 빈 문자열일 때
            view.makeToast("이메일을 입력해주세요!", position: .top)              // 토스트 얼럿 노출 -> 리턴
            return
        } else if password.isEmpty {                                        // 비밀번호가 빈 문자열일 때
            view.makeToast("비밀번호를 입력해주세요!", position: .top)             // 토스트 얼럿 노출 -> 리턴
            return
        }
        
        IndicatorManager.shared.start()                                     // 로딩 인디케이터 시작
        
        let userInput = (email, password)                                   // 유저가 입력한 이메일, 비밀번호
        
        // 파이어베이스 이메일 로그인 시작
        AuthManager.shared.login(userInput) { [weak self] result in
            IndicatorManager.shared.stop()                                  // 로딩 인디케이터 제거
            
            guard let self = self else { return }
            
            switch result {
            case .success(let authResult):                                  // 로그인 성공 (`로그인 결과`)
                print("🎉 이메일 로그인 성공", authResult)
                
                if isRevokeLogin == true {                                  // 탈퇴전 로그인은 화면 닫기 (예외처리)
                    dismiss(animated: true, completion: isRevokeLoginCompletion)
                    
                    return
                }
                
                let rootVC = TabBarController()                             // 메인 탭바 컨트롤러
                self.changeRootVC(rootVC, animated: true)                   // 메인 탭바 컨트롤러로 루트 뷰컨 변경
                
                DBManager.shared.fetchDocument(.user, documentName: authResult.user.uid, type: User.self) { result in
                    if case var .success(fetchedUser) = result {
                        fetchedUser.lastSignInDate = authResult.user.metadata.lastSignInDate
                        
                        DBManager.shared.save(.user, documentName: authResult.user.uid, data: fetchedUser) { _ in}
                    }
                }
                
            case .failure(let error):                                            // 로그인 실패 (`에러`)
                self.view.makeToast("사용자 정보를 찾을 수 없어요!", position: .top)    // 토스트 얼럿 노출
                print("🎉 이메일 로그인 실패", error)
            }
        }
    }
    
    /// Apple 로그인 버튼 눌렀을 때
    @objc func didTapAppleLogInButton() {
        IndicatorManager.shared.start()                                     // 로딩 인디케이터 시작
        
        let nonce = randomNonceString()                                     // 난수 생성
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()              // 애플 로그인
        let request = appleIDProvider.createRequest()                       // 로그인 요청 생성
        request.requestedScopes = [.fullName, .email]                       // 이름, 이메일 요청
        request.nonce = sha256(nonce)                                       // SHA256 해시 난수
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])   // 애플 로그인 모달
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()                                                   // 모달 노출
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // 애플 로그인 완료
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8),
              let nonce = currentNonce else {
            IndicatorManager.shared.stop()                                  // 로딩 인디케이터 제거
            view.makeToast("다시 시도해주세요!", position: .top)
            return
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            IndicatorManager.shared.stop()                                  // 로딩 인디케이터 제거
            
            guard let self = self else { return }
            
            if let authResult = authResult {
                
                if isRevokeLogin == true {                                  // 탈퇴전 로그인은 화면 닫기 (예외처리)
                    dismiss(animated: true, completion: isRevokeLoginCompletion)
                    
                    return
                }
                
                DBManager.shared.fetchDocument(.user, documentName: authResult.user.uid, type: User.self) { result in
                    switch result {
                    case .success(var fetchedUser): // 로그인
                        
                        fetchedUser.lastSignInDate = authResult.user.metadata.lastSignInDate
                        
                        DBManager.shared.save(.user, documentName: authResult.user.uid, data: fetchedUser) { _ in}
                        
                        let rootVC = TabBarController()             // 메인 탭바 컨트롤러
                        self.changeRootVC(rootVC, animated: true)   // 메인 탭바 컨트롤러로 루트 뷰컨 변경
                        
                    case .failure(_): // 로그인 시 회원정보가 없으면, 회원가입
                        
                        let id = authResult.user.uid
                        let email = authResult.user.email ?? "NIL"
                        let name = appleIDCredential.fullName?.givenName ?? String(email.split(separator: "@").first ?? "NIL")
                        let createdDate = authResult.user.metadata.creationDate
                        let lastSignInDate = authResult.user.metadata.lastSignInDate
                        
                        let user = User(
                            id: id,
                            email: email,
                            name: name,
                            createdDate: createdDate,
                            lastSignInDate: lastSignInDate,
                            isEmailVerified: false
                        )
                        
                        // 유저 정보 저장 시작
                        DBManager.shared.save(
                            .user,
                            documentName: user.id,
                            data: user
                        ) { dbResult in
                            switch dbResult {
                            case .success(_):                               // 유저 저장 성공
                                let rootVC = TabBarController()             // 메인 탭바 컨트롤러
                                self.changeRootVC(rootVC, animated: true)   // 메인 탭바 컨트롤러로 루트 뷰컨 변경
                            case .failure(let error):
                                // TODO: - 유저 저장 실패 처리
                                print("🎉 유저 저장 실패", error)
                            }
                        }
                    }
                }
            }
            
            if let error = error {
                view.makeToast("사용자 정보를 찾을 수 없어요!", position: .top)     // 토스트 얼럿 노출
            }
        }
    }
    
    // 애플 로그인 취소/에러
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        IndicatorManager.shared.stop()                                  // 로딩 인디케이터 제거
    }
}
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

// MARK: - UI 레이아웃
private extension LoginViewController {
    
    /// 내비게이션 바 설정
    func setupNavigationBar() {
        navigationItem.title = "로그인"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    /// 레이아웃 설정
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
            emailTextField,
            passwordTextField,
            loginButton,
            appleLoginButton,
            lineSeparator,
            moveToSignUpButton
        ].forEach {
            contentView.addSubview($0)
        }
        
        emailTextField.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
        passwordTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(emailTextField.snp.bottom).offset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
        loginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
        lineSeparator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset * 3)
            $0.top.equalTo(loginButton.snp.bottom).offset(Constant.defaultInset * 2)
        }
        appleLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(lineSeparator.snp.bottom).offset(Constant.defaultInset * 2)
            $0.height.equalTo(48.0)
        }
        moveToSignUpButton.snp.makeConstraints {
            $0.centerX.equalTo(appleLoginButton.snp.centerX)
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(Constant.defaultInset)
            $0.bottom.equalToSuperview()
        }
    }
    
    /// 탈퇴전 로그인 화면 예외처리
    func setupViewWhenIsRevokeLogin() {
        guard let isRevokeLogin = isRevokeLogin,
              isRevokeLogin else {
            return
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(didTapDismissButton)
        )
        
        moveToSignUpButton.isHidden = true
    }
}
