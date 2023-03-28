//
//  AuthManager.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import Foundation
import FirebaseAuth

protocol AuthManagerProtocol {
    typealias UserInput = (email: String, password: String)
    func getCurrentUser() -> User?
    func login(_ userInput: UserInput, completion: @escaping (Result<AuthDataResult, Error> ) -> Void)
    func signUp(_ userInput: UserInput, completion: @escaping (Result<AuthDataResult, Error>) -> Void)
}

final class AuthManager: AuthManagerProtocol {
    static let shared = AuthManager()
    
    private init() {}
    
    private let firAuth = Auth.auth()
    
    func getCurrentUser() -> User? {
        return firAuth.currentUser
    }
    
    func login(_ userInput: UserInput, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        firAuth.signIn(withEmail: userInput.email, password: userInput.password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let authResult = authResult {
                completion(.success(authResult))
                return
            }
        }
    }
    
    func signUp(_ userInput: UserInput, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        firAuth.createUser(withEmail: userInput.email, password: userInput.password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let authResult = authResult {
                completion(.success(authResult))
                return
            }
        }
    }
    
    func logout() -> Bool {
        do {
            try firAuth.signOut()
            return true
        } catch {
            return false
//            fatalError("로그아웃 실패")
        }
    }
}
