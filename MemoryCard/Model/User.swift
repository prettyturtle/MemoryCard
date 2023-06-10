//
//  User.swift
//  MemoryCard
//
//  Created by yc on 2023/04/06.
//

import Foundation

/// 유저 정보
struct User: Codable {
    let id: String      // ID
    let email: String   // 이메일
    var name: String?
    var profileImgURL: String?
    var createdDate: Date?
    var lastSignInDate: Date?
}
