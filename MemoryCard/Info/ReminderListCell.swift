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
				Label("", systemImage: "trash")
			}
			.tint(.red)
			
			Button {
				viewModel.isModify = true
				viewModel.modifiedReminder = reminder
				viewModel.isShowAddReminderView = true
			} label: {
				Label("", systemImage: "square.and.pencil")
			}
			.tint(.blue)
		}
	}
	
	private func ReminderToggleLabel() -> some View {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = .init(identifier: "ko_KR")
		dateFormatter.dateFormat = "a hh:mm"
		let dateString = dateFormatter.string(from: reminder.date) // "12 AM"
		
		return VStack(alignment: .leading, spacing: 8) {
			Text(reminder.title)
				.font(UIFont.Pretendard.m24.font)
				.lineLimit(1)
			
			Text(dateString)
				.font(UIFont.Pretendard.m18.font)
				.foregroundColor(.secondary)
			
			HStack(spacing: 4) {
				ForEach(reminder.weekDayList.sorted { $0.rawValue < $1.rawValue }, id: \.self) { weekDay in
					Text(weekDay.text)
						.foregroundColor(.secondary)
						.font(UIFont.Pretendard.m16.font)
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
