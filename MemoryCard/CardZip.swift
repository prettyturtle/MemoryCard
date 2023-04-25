//
//  CardZip.swift
//  MemoryCard
//
//  Created by yc on 2023/04/04.
//

import Foundation

/// 카드 집
struct CardZip: Codable {
    var id: String = UUID().uuidString  // ID
    let folderName: String              // 카드 폴더 명
    let cards: [Card]                   // 카드 배열
    let mIdx: String                    // 유저 아이디
    
    
    static var mockData: [CardZip] {
        return (1...10).map {
            CardZip(folderName: "TEST\($0)", cards: [Card(id: $0, front: Card.CardContent(content: "front \($0)"), back: Card.CardContent(content: "back \($0)"))], mIdx: AuthManager.shared.getCurrentUser()?.uid ?? "")
        }
    }
}
