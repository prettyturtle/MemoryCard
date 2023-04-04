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
}

/// DB 콜렉션 타입
enum DBCollectionType: String {
    case card = "Card" // 카드 콜렉션
    
    var collectionName: String { // 콜렉션 명
        return self.rawValue
    }
}
