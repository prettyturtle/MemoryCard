//
//  User.swift
//  MemoryCard
//
//  Created by yc on 2023/04/06.
//

import Foundation

/// 유저 정보
struct User: Codable, Equatable {
	let id: String						// ID
	let email: String					// 이메일
	var name: String?					// 이름
	var profileImgURL: String?			// 프로필 이미지 URL
	var createdDate: Date?				// 가입 날짜
	var lastSignInDate: Date?			// 마지막 로그인 날짜
	var isEmailVerified: Bool? = false	// 이메일 인증 여부
	var pushToken: String?				// 푸시 토큰
	var appVersion: Double?				// 앱 버전
}
