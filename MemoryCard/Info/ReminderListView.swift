//
//  ReminderListView.swift
//  MemoryCard
//
//  Created by yc on 2023/07/05.
//

import SwiftUI
import UserNotifications

struct ReminderListView: View {
    @ObservedObject var viewModel: ReminderListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            TotalReminderToggleView()
            
            Divider()
            
            if !viewModel.isAllowReminder || viewModel.reminderList.isEmpty {
                ReminderListEmptyView()
            } else {
                ReminderToggleListView()
            }
        }
        .navigationTitle("암기 리마인더 설정")
        .toolbar {
            AddReminderToolbarItem()
        }
        .onAppear {
            viewModel.viewOnAppear()
        }
        .sheet(isPresented: $viewModel.isShowAddReminderView) {
            print("HELLO")
        } content: {
            AddReminderView(
                isShow: $viewModel.isShowAddReminderView,
                savedReminder: $viewModel.savedReminder
            )
        }
        .alert("알림 권한 허용", isPresented: $viewModel.isShowAllowNotiAlert) {
            AlertMoveToSettings()
        } message: {
            Text("암기 리마인더를 사용하려면 \"설정\"에서 알림을 허용해주세요")
        }
        .onChange(of: viewModel.savedReminder) { newReminder in
            if let newReminder = newReminder {
                viewModel.reminderList.insert(newReminder, at: 0)
                viewModel.savedReminder = nil
            }
        }
        .onChange(of: viewModel.isAllowReminder) { isToggleAllow in
            viewModel.onChangeIsAllowReminder(isToggleAllow)
        }
    }
}

private extension ReminderListView {
    func TotalReminderToggleView() -> some View {
        Toggle(isOn: $viewModel.isAllowReminder) {
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
    }
    
    func ReminderListEmptyView() -> some View {
        Group {
            Spacer()
            
            Image(systemName: "clock.badge")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width / 2.0, height: UIScreen.main.bounds.width / 2.0)
                .foregroundColor(Color(uiColor: .placeholderText))
            
            Spacer()
        }
    }
    
    func ReminderToggleListView() -> some View {
        List(viewModel.reminderList) { reminder in
            ReminderListCell(viewModel: viewModel, reminder: reminder)
        }
        .listStyle(.plain)
    }
    
    func AddReminderToolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.isAllowReminder {
                Button {
                    viewModel.isShowAddReminderView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    func AlertMoveToSettings() -> some View {
        Group {
            Button(role: nil) {
                DispatchQueue.main.async {
                    Task {
                        await viewModel.moveToSettings()
                    }
                }
            } label: {
                Text("설정으로 이동")
            }
            
            Button(role: .cancel) {
            } label: {
                Text("취소")
            }
        }
    }
}
