//
//  Card.swift
//  MemoryCard
//
//  Created by yc on 2023/04/02.
//

import Foundation

/// 카드
struct Card {
    let id: Int             // 고유값
    let front: CardContent  // 앞면
    let back: CardContent   // 뒷면
    
    /// 카드 내용
    struct CardContent {
        let content: String // 내용
    }
    
    /// 빈 카드 생성하는 함수
    /// - Parameter id: 카드 ID
    /// - Returns: 빈 카드
    static func createDefault(id: Int) -> Card {
        return Card(id: id, front: CardContent(content: ""), back: CardContent(content: ""))
    }
}
