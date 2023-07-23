//
//  Reminder.swift
//  MemoryCard
//
//  Created by yc on 2023/07/23.
//

import Foundation

final class Reminder: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var weekDayList: [WeekDay]
    var cardZipID: String?
    var isOn: Bool
    var createdAt: Date
    
    init(
        id: UUID,
        title: String,
        date: Date,
        weekDayList: [WeekDay],
        cardZipID: String? = nil,
        isOn: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.weekDayList = weekDayList
        self.cardZipID = cardZipID
        self.isOn = isOn
        self.createdAt = createdAt
    }
    
    static func == (_ lhs: Reminder, _ rhs: Reminder) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let mockData = (1...10).map {
        Reminder(id: UUID(), title: "Title\($0)", date: Date.now, weekDayList: WeekDay.allCases, cardZipID: nil, isOn: false, createdAt: .now)
    }
}
