//
//  WeekDay.swift
//  MemoryCard
//
//  Created by yc on 2023/07/23.
//

import Foundation

enum WeekDay: Int, CaseIterable, Codable {
    case sun, mon, tue, wed, thu, fri, sat
    
    var value: Int { self.rawValue + 1 }
    var text: String {
        switch self {
        case .sun: return "일"
        case .mon: return "월"
        case .tue: return "화"
        case .wed: return "수"
        case .thu: return "목"
        case .fri: return "금"
        case .sat: return "토"
        }
    }
}
