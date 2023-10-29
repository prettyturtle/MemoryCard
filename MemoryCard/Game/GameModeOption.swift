//
//  GameModeOption.swift
//  MemoryCard
//
//  Created by yc on 2023/10/30.
//

import Foundation

enum GameModeOption {
    case sort       // 정렬 (순서대로, 거꾸로, 랜덤)
    case state      // 앞, 뒤, 랜덤
    case skip       // 스킵 가능 여부 (스킵 가능, 스킵 불가능)
    case sunjiCount // 선지 개수 (2개, 3개, 4개) - 퀴즈 모드 전용
    case level      // 난이도 (정확한 채점, 포함하면 정답) - 입력 모드 전용
    
    var title: String {
        switch self {
        case .sort:
            return "카드 순서"
        case .state:
            return "암기 대상"
        case .skip:
            return "스킵 가능 여부"
        case .sunjiCount:
            return "선지 개수"
        case .level:
            return "채점 기준"
        }
    }
    
    var selectionList: [(idx: Int, text: String)] {
        switch self {
        case .sort:
            return [(0, "순서대로"), (1, "거꾸로"), (2, "랜덤")]
        case .state:
            return [(0, "앞면"), (1, "뒷면"), (2, "랜덤")]
        case .skip:
            return [(0, "스킵 가능"), (1, "스킵 불가능")]
        case .sunjiCount:
            return [(0, "2개"), (1, "3개"), (2, "4개")]
        case .level:
            return [(0, "정확히 일치"), (1, "문자 포함")]
        }
    }
    
    var defaultValue: Int {
        switch self {
        case .sort:
            return 0
        case .state:
            return 0
        case .skip:
            return 0
        case .sunjiCount:
            return 0
        case .level:
            return 0
        }
    }
}
