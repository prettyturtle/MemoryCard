//
//  AuthManager.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import Foundation
import FirebaseAuth

/// 인증 프로토콜
protocol AuthManagerProtocol {
    /// (이메일, 비밀번호)
    typealias UserInput = (email: String, password: String)
    
    /// 현재 로그인된 유저를 반환하는 함수
    /// - Returns: 현재 로그인된 유저
    func getCurrentUser() -> User?
    
    /// 로그인 함수
    /// - Parameters:
    ///   - userInput: (이메일, 비밀번호)
    ///   - completion: 로그인 완료 후 이벤트
    func login(_ userInput: UserInput, completion: @escaping (Result<AuthDataResult, Error> ) -> Void)
    
    /// 회원가입 함수
    /// - Parameters:
    ///   - userInput: (이메일, 비밀번호)
    ///   - completion: 회원가입 완료 후 이벤트
    func signUp(_ userInput: UserInput, completion: @escaping (Result<AuthDataResult, Error>) -> Void)
    
    
    /// 로그아웃 함수
    /// - Returns: 로그아웃 성공 여부
    func logout() -> Bool
}

/// 인증 관련 클래스
///
/// 싱글톤 객체를 사용한다
final class AuthManager: AuthManagerProtocol {
    static let shared = AuthManager() // 싱글톤 객체 생성
    
    private init() {}
    
    private let firAuth = Auth.auth() // 파이어베이스 Auth
    
    // 현재 유저 반환
    func getCurrentUser() -> User? {
        return firAuth.currentUser
    }
    
    // 로그인
    func login(_ userInput: UserInput, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        
        // 파이어베이스 이메일 로그인 시작
        firAuth.signIn(withEmail: userInput.email, password: userInput.password) { authResult, error in
            if let authResult = authResult {
                completion(.success(authResult))    // 로그인 성공 (`로그인 정보`)
                return
            }
            
            if let error = error {
                completion(.failure(error))         // 로그인 실패 (`에러`)
                return
            }
        }
    }
    
    // 회원가입
    func signUp(_ userInput: UserInput, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        
        // 파이어베이스 이메일 회원가입 시작
        firAuth.createUser(withEmail: userInput.email, password: userInput.password) { authResult, error in
            if let authResult = authResult {
                completion(.success(authResult))    // 회원가입 성공 (`회원가입 정보`)
                return
            }
            
            if let error = error {
                completion(.failure(error))         // 회원가입 실패 (`에러`)
                return
            }
        }
    }
    
    // 로그아웃
    func logout() -> Bool {
        do {
            try firAuth.signOut()   // 로그아웃 시도
            
            return true             // 로그아웃 성공
        } catch {
            return false            // 로그아웃 실패
        }
    }
}
