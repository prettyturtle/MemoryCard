//
//  ReminderListCell.swift
//  MemoryCard
//
//  Created by yc on 2023/07/30.
//

import SwiftUI

struct ReminderListCell: View {
    
    @Binding var reminderList: [Reminder]
    @Binding var reminder: Reminder
    
    var body: some View {
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
            ReminderToggleLabel()
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
    
    private func ReminderToggleLabel() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reminder.title)
                .font(.system(size: 20, weight: .medium))
            
            HStack(spacing: 4) {
                ForEach(reminder.weekDayList.sorted { $0.rawValue < $1.rawValue }, id: \.self) { weekDay in
                    Text(weekDay.text)
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 25, height: 25)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.secondary.opacity(0.3), lineWidth: 1.0)
                        }
                }
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
                reminderList = updatedReminderList.sorted { $0.createdAt.compare($1.createdAt) == .orderedDescending }
            }
        }
    }
    
    private func deleteReminder(_ reminder: Reminder) {
        if let mIdx = AuthManager.shared.getCurrentUser()?.id {
            let udm = UserDefaultsManager<Reminder>(key: .reminderList(mIdx: mIdx))
            
            if let deletedReminderList = udm.delete(reminder) {
                reminderList = deletedReminderList.sorted { $0.createdAt.compare($1.createdAt) == .orderedDescending }
            }
        }
    }
}

struct ReminderListCell_Previews: PreviewProvider {
    static var previews: some View {
        return ReminderListCell(reminderList: .constant(Reminder.mockData), reminder: .constant(Reminder.mockData.first!))
    }
}
