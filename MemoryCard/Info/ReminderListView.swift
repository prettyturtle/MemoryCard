//
//  ReminderListView.swift
//  MemoryCard
//
//  Created by yc on 2023/07/05.
//

import SwiftUI
import UserNotifications

struct ReminderListView: View {
    
    @State var reminderList = [Reminder]()
    @State var isShowAddReminderView = false
    @State var savedReminder: Reminder?
    
    var body: some View {
        VStack(spacing: 0) {
            Text("암기 리마인더 설정")
                .font(.system(size: 20, weight: .semibold))
            Text("원하는 시간에 암기를 시작해보세요")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            if reminderList.isEmpty {
                Spacer()
            } else {
                List($reminderList) { $reminder in
                    Toggle(isOn: Binding<Bool>(get: {
                        return reminder.isOn
                    }, set: { newIsOn, _ in
                        if !newIsOn {
                            Task {
                                await cancelReminder(reminder)
                                reminder.isOn = newIsOn
                                
                                updateReminder(reminder)
                            }
                        } else {
                            registerReminder(reminder)
                            
                            reminder.isOn = newIsOn
                            
                            updateReminder(reminder)
                        }
                    })) {
                        Text(reminder.title)
                    }
                    .tint(.orange)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            Task {
                                await cancelReminder(reminder)
                                deleteReminder(reminder)
                            }
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
                .listStyle(.plain)
                .padding(.top, 16)
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
            let unNotiCenter = UNUserNotificationCenter.current()
            let notiOptions: UNAuthorizationOptions = [.alert, .badge]
            
            unNotiCenter.requestAuthorization(options: notiOptions, completionHandler: { _,_ in })
            
            
            if let mIdx = AuthManager.shared.getCurrentUser()?.id {
                let udm = UserDefaultsManager<Reminder>(key: .reminderList(mIdx: mIdx))
                
                let savedReminderList = udm.read() ?? []
                
                reminderList = savedReminderList
            }
        }
        .sheet(isPresented: $isShowAddReminderView) {
            print("HELLO")
        } content: {
            AddReminderView(isShow: $isShowAddReminderView, savedReminder: $savedReminder)
        }
        .onChange(of: savedReminder) { newReminder in
            if let newReminder = newReminder {
                reminderList.insert(newReminder, at: 0)
                savedReminder = nil
            }
        }
    }
    
    private func cancelReminder(_ reminder: Reminder) async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        
        let deletedReminderIDs = requests.map { $0.identifier }.filter { $0.hasPrefix(reminder.id.uuidString) }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: deletedReminderIDs)
    }
    
    private func registerReminder(_ reminder: Reminder) {
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = reminder.title
        notificationContent.body = "알림을 눌러 지금 바로 암기를 시작해봐요 👏"
        notificationContent.badge = 1
        notificationContent.userInfo = ["cardZipID": reminder.cardZipID ?? ""]
        
        let reminderDate = Calendar.current.dateComponents([.hour, .minute], from: reminder.date)
        
        let hour = reminderDate.hour
        let minute = reminderDate.minute
        
        for i in 0..<reminder.weekDayList.count {
            
            var dateComponent = DateComponents()
            dateComponent.hour = hour
            dateComponent.minute = minute
            dateComponent.weekday = reminder.weekDayList[i].value
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
            
            let notificationRequest = UNNotificationRequest(
                identifier: reminder.id.uuidString + "_\(i)",
                content: notificationContent,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(notificationRequest)
        }
    }
    
    private func updateReminder(_ reminder: Reminder) {
        if let mIdx = AuthManager.shared.getCurrentUser()?.id {
            let udm = UserDefaultsManager<Reminder>(key: .reminderList(mIdx: mIdx))
            
            if let updatedReminderList = udm.update(reminder) {
                reminderList = updatedReminderList
            }
        }
    }
    
    private func deleteReminder(_ reminder: Reminder) {
        if let mIdx = AuthManager.shared.getCurrentUser()?.id {
            let udm = UserDefaultsManager<Reminder>(key: .reminderList(mIdx: mIdx))
            
            if let deletedReminderList = udm.delete(reminder) {
                reminderList = deletedReminderList
            }
        }
    }
}

class Reminder: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var weekDayList: [WeekDay]
    var cardZipID: String?
    var isOn: Bool
    
    init(
        id: UUID,
        title: String,
        date: Date,
        weekDayList: [WeekDay],
        cardZipID: String? = nil,
        isOn: Bool
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.weekDayList = weekDayList
        self.cardZipID = cardZipID
        self.isOn = isOn
    }
    
    static func == (_ lhs: Reminder, _ rhs: Reminder) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let mockData = (1...10).map {
        Reminder(id: UUID(), title: "Title\($0)", date: Date.now, weekDayList: WeekDay.allCases, cardZipID: nil, isOn: false)
    }
}

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
