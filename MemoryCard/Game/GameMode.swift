//
//  GameMode.swift
//  MemoryCard
//
//  Created by yc on 2023/10/29.
//

import Foundation

enum GameMode {
    case quiz
    case keyboard
    
    var title: String {
        switch self {
        case .quiz:
            return "퀴즈 챌린지"
        case .keyboard:
            return "입력 레이스"
        }
    }
    
    var description: String {
        switch self {
        case .quiz:
            return "암기한 내용을 게임으로 다시 확인해요.\n문제를 보고 선지 중에서 정답을 골라주세요!"
        case .keyboard:
            return "암기한 내용을 게임으로 다시 확인해요.\n문제를 보고 정답을 직접 입력해주세요!"
        }
    }
}
