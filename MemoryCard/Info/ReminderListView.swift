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
    @State var isAllowReminder = false
    @State var isShowAllowNotiAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            Toggle(isOn: $isAllowReminder) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("리마인더 알림 허용")
                        .font(.system(size: 18, weight: .medium))
                    
                    Text("원하는 시간에 암기를 시작해보세요")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .tint(.cyan)
            .padding(16)
            
            Divider()
            
            if isAllowReminder {
                if reminderList.isEmpty {
                    Spacer()
                    
                    Image(systemName: "clock.badge")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width / 2.0, height: UIScreen.main.bounds.width / 2.0)
                        .foregroundColor(Color(uiColor: .placeholderText))
                    
                    Spacer()
                } else {
                    List($reminderList) { $reminder in
                        ReminderListCell(reminderList: $reminderList, reminder: $reminder)
                    }
                    .listStyle(.plain)
                }
            } else {
                Spacer()
            }
        }
        .navigationTitle("암기 리마인더 설정")
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isAllowReminder {
                    Button {
                        isShowAddReminderView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            if let mIdx = AuthManager.shared.getCurrentUser()?.id {
                let udm = UserDefaultsManager<Reminder>(key: .reminderList(mIdx: mIdx))
                
                let savedReminderList = udm.read() ?? []
                
                reminderList = savedReminderList.sorted { $0.createdAt.compare($1.createdAt) == .orderedDescending }
            }
            
            let isAllowReminderNoti = UserDefaults.standard.bool(forKey: "IS_ALLOW_REMINDER_NOTI")
            
            isAllowReminder = isAllowReminderNoti
        }
        .sheet(isPresented: $isShowAddReminderView) {
            print("HELLO")
        } content: {
            AddReminderView(isShow: $isShowAddReminderView, savedReminder: $savedReminder)
        }
        .alert("회원탈퇴", isPresented: $isShowAllowNotiAlert) {
            Button(role: nil) {
                DispatchQueue.main.async {
                    Task {
                        await moveToSettings()
                    }
                }
            } label: {
                Text("설정으로 이동")
            }
            
            Button(role: .cancel) {
            } label: {
                Text("취소")
            }
        } message: {
            Text("암기 리마인더를 사용하려면 \"설정\"에서 알림을 허용해주세요")
        }
        .onChange(of: savedReminder) { newReminder in
            if let newReminder = newReminder {
                reminderList.insert(newReminder, at: 0)
                savedReminder = nil
            }
        }
        .onChange(of: isAllowReminder) { isToggleAllow in
            UserDefaults.standard.setValue(isToggleAllow, forKey: "IS_ALLOW_REMINDER_NOTI")
            
            let unNotiCenter = UNUserNotificationCenter.current()
            
            if isToggleAllow {
                let notiOptions: UNAuthorizationOptions = [.alert, .badge]
                
                Task {
                    let settings = await unNotiCenter.notificationSettings()
                    
                    let allowStatus = settings.authorizationStatus
                    
                    switch allowStatus {
                    case .notDetermined:
                        let isAllow = try await unNotiCenter.requestAuthorization(options: notiOptions)
                        
                        isAllowReminder = isAllow
                    case .denied:
                        isAllowReminder = false
                        isShowAllowNotiAlert = true
                    default:
                        break
                    }
                }
                
                for reminder in reminderList {
                    if reminder.isOn {
                        registerReminder(reminder)
                    }
                }
            } else {
                unNotiCenter.removeAllPendingNotificationRequests()
            }
        }
    }
    
    @MainActor
    private func moveToSettings() async {
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
