//
//  DBManager.swift
//  MemoryCard
//
//  Created by yc on 2023/04/04.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

/// DB 관련 클래스
final class DBManager {
    static let shared = DBManager() // 싱글톤 객체
    
    private init() {}
    
    private let db = Firestore.firestore() // 파이어베이스 DB
     
    /// 데이터 저장
    /// - Parameters:
    ///   - collectionType: 콜렉션 타입
    ///   - documentName: 도큐먼트명
    ///   - data: 저장할 데이터
    ///   - completion: 완료 컴플리션
    func save(
        _ collectionType: DBCollectionType,
        documentName: String,
        data: Encodable,
        completion: (@escaping (Result<Void, Error>) -> Void)
    ) {
        do {
            try db
                .collection(collectionType.collectionName)  // 콜렉션 명 설정
                .document(documentName)                     // 도큐먼트 명 설정
                .setData(
                    from: data,
                    completion: { error in
                        if let error = error {              // 저장 실패시
                            completion(.failure(error))     // 실패 컴플리션
                            return
                        }
                        
                        completion(.success(()))            // 성공 컴플리션
                        return
                    }
                )                                           // 데이터 저장 시도
        } catch {                                           // 데이터 저장 실패시
            completion(.failure(error))                     // 실패 컴플리션
        }
    }
    
    
    /// 데이터 가져오기(도큐먼트)
    ///
    /// - Parameters:
    ///   - collectionType: 콜렉션 타입
    ///   - documentName: 가져올 도큐먼트명
    ///   - type: 파싱할 타입
    ///   - completion: 완료 컴플리션
    func fetchDocument<T: Decodable>(
        _ collectionType: DBCollectionType,
        documentName: String,
        type: T.Type,
        completion: (@escaping (Result<T, Error>) -> Void)
    ) {
        db
            .collection(collectionType.collectionName)      // 콜렉션 명 설정
            .document(documentName)                         // 가져올 도큐먼트 설정
            .getDocument(as: type, completion: completion)  // 도큐먼트 가져오기
    }
    
    
    /// 데이터 가져오기(콜렉션)
    /// - Parameters:
    ///   - collectionType: 가져올 콜렉션
    ///   - type: 도큐먼트를 파싱할 타입
    ///   - completion: 완료 컴플리션
    func fetchDocuments<T: Decodable>(
        _ collectionType: DBCollectionType,
        type: T.Type,
        completion: (@escaping (Result<T, Error>) -> Void)
    ) {
        db
            .collection(collectionType.collectionName)                  // 콜렉션 명 설정
            .getDocuments { snapshot, error in                          // 도큐먼트들 가져오기
                if let error = error {
                    completion(.failure(error))                         // 실패시 컴플리션 (`에러`)
                    return
                }
                
                if let snapshot = snapshot {                            // 성공시
                    let documents = snapshot.documents                  // 가져온 도큐먼트들
                    
                    for document in documents {
                        do {
                            let docData = try document.data(as: type)   // 도큐먼트 데이터 파싱
                            
                            completion(.success(docData))               // 성공시 컴플리션 (`도큐먼트 데이터`)
                        } catch {
                            completion(.failure(error))                 // 실패시 컴플리션 (`에러`)
                        }
                    }
                }
            }
    }
}

/// DB 콜렉션 타입
enum DBCollectionType: String {
    case card = "Card" // 카드 콜렉션
    case user = "User" // 유저 콜렉션
    
    var collectionName: String { // 콜렉션 명
        return self.rawValue
    }
}
