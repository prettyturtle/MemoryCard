//
//  ReminderListViewModel.swift
//  MemoryCard
//
//  Created by yc on 2023/08/01.
//

import SwiftUI

final class ReminderListViewModel: ObservableObject {
    @Published var reminderList = [Reminder]()
    @Published var isShowAddReminderView = false
    @Published var savedReminder: Reminder?
    @Published var isAllowReminder = false
    @Published var isShowAllowNotiAlert = false
}

extension ReminderListViewModel {
    func viewOnAppear() {
        if let mIdx = AuthManager.shared.getCurrentUser()?.id {
            let udm = UserDefaultsManager<Reminder>(key: .reminderList(mIdx: mIdx))
            
            let savedReminderList = udm.read() ?? []
            
            reminderList = savedReminderList.sorted { $0.createdAt.compare($1.createdAt) == .orderedDescending }
        }
        
        let isAllowReminderNoti = UserDefaults.standard.bool(forKey: "IS_ALLOW_REMINDER_NOTI")
        
        isAllowReminder = isAllowReminderNoti
    }
    
    func onChangeIsAllowReminder(_ isAllow: Bool) {
        UserDefaults.standard.setValue(isAllow, forKey: "IS_ALLOW_REMINDER_NOTI")
        
        let unNotiCenter = UNUserNotificationCenter.current()
        
        if isAllow {
            let notiOptions: UNAuthorizationOptions = [.alert, .badge]
            
            Task {
                let settings = await unNotiCenter.notificationSettings()
                
                let allowStatus = settings.authorizationStatus
                
                switch allowStatus {
                case .notDetermined:
                    let authorizationResponse = try await unNotiCenter.requestAuthorization(options: notiOptions)
                    
                    isAllowReminder = authorizationResponse
                case .denied:
                    isAllowReminder = false
                    isShowAllowNotiAlert = true
                default:
                    break
                }
                
                if isAllowReminder {
                    for reminder in reminderList {
                        if reminder.isOn {
                            registerReminder(reminder)
                        }
                    }
                }
            }
            
            
        } else {
            unNotiCenter.removeAllPendingNotificationRequests()
        }
    }
}

extension ReminderListViewModel {
    @MainActor
    func moveToSettings() async {
        var settingsURLString = UIApplication.openSettingsURLString
        
        if #available(iOS 16.0, *) {
            settingsURLString = UIApplication.openNotificationSettingsURLString
        } else if #available(iOS 15.4, *) {
            settingsURLString = UIApplicationOpenNotificationSettingsURLString
        }
        
        guard let settingsURL = URL(string: settingsURLString) else {
            return
        }
        
        await UIApplication.shared.open(settingsURL)
    }
    
    func cancelReminder(_ reminder: Reminder) async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        
        let deletedReminderIDs = requests.map { $0.identifier }.filter { $0.hasPrefix(reminder.id.uuidString) }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: deletedReminderIDs)
    }
    
    func registerReminder(_ reminder: Reminder) {
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
    
    func updateReminder(_ reminder: Reminder) {
        if let mIdx = AuthManager.shared.getCurrentUser()?.id {
            let udm = UserDefaultsManager<Reminder>(key: .reminderList(mIdx: mIdx))
            
            if let updatedReminderList = udm.update(reminder) {
                reminderList = updatedReminderList.sorted { $0.createdAt.compare($1.createdAt) == .orderedDescending }
            }
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        if let mIdx = AuthManager.shared.getCurrentUser()?.id {
            let udm = UserDefaultsManager<Reminder>(key: .reminderList(mIdx: mIdx))
            
            if let deletedReminderList = udm.delete(reminder) {
                reminderList = deletedReminderList.sorted { $0.createdAt.compare($1.createdAt) == .orderedDescending }
            }
        }
    }
}
