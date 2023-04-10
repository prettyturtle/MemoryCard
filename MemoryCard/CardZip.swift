//
//  CardZip.swift
//  MemoryCard
//
//  Created by yc on 2023/04/04.
//

import Foundation

/// 카드 집
struct CardZip: Codable {
    let folderName: String  // 카드 폴더 명
    let cards: [Card]       // 카드 배열
    let mIdx: String        // 유저 아이디
}
