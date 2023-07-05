//
//  ReminderListView.swift
//  MemoryCard
//
//  Created by yc on 2023/07/05.
//

import SwiftUI

struct ReminderListView: View {
    
    @State var reminderList = [Reminder]()
    @State var isShowAddReminderView = false
    
    var body: some View {
        Group {
            if reminderList.isEmpty {
                Text("암기 리마인더를 설정해보세요")
            } else {
                List($reminderList) { reminder in
                    Toggle(isOn: reminder.isOn) {
                        Text(reminder.title.wrappedValue)
                    }
                    .tint(.red)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowAddReminderView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            reminderList = Reminder.mockData
        }
        .sheet(isPresented: $isShowAddReminderView) {
            print("HELLO")
        } content: {
            Text("ADD REMINDER VIEW")
        }
    }
}

struct Reminder: Decodable, Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var isOn: Bool
    var cardZip: CardZip?
    
    static let mockData = (1...10).map {
        Reminder(id: UUID(), title: "Title\($0)", date: Date.now, isOn: false, cardZip: nil)
    }
}
