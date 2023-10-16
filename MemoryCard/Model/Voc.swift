//
//  Voc.swift
//  MemoryCard
//
//  Created by yc on 2023/10/16.
//

import SwiftUI

struct Voc: Codable, Identifiable {
    var id: String = UUID().uuidString
    let mIdx: String
    let title: String
    let content: String
    let createdDate: Date
    
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    var formattedDate: String {
        return formatDate(date: createdDate)
    }
}
