//
//  ReminderListCell.swift
//  MemoryCard
//
//  Created by yc on 2023/07/30.
//

import SwiftUI

struct ReminderListCell: View {
    @ObservedObject var viewModel: ReminderListViewModel
    var reminder: Reminder
    
    var body: some View {
        Toggle(isOn: Binding<Bool>(get: {
            return reminder.isOn
        }, set: { newIsOn, _ in
            if !newIsOn {
                Task {
                    await viewModel.cancelReminder(reminder)
                    
                    reminder.isOn = newIsOn
                    
                    viewModel.updateReminder(reminder)
                }
            } else {
                viewModel.registerReminder(reminder)
                
                reminder.isOn = newIsOn
                
                viewModel.updateReminder(reminder)
            }
        })) {
            ReminderToggleLabel()
        }
        .tint(.orange)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                Task {
                    await viewModel.cancelReminder(reminder)
                    viewModel.deleteReminder(reminder)
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
}
