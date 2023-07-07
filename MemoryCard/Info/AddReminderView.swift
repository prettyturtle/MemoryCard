//
//  AddReminderView.swift
//  MemoryCard
//
//  Created by yc on 2023/07/06.
//

import SwiftUI

struct AddReminderView: View {
    
    @Binding var isShow: Bool
    @State var selectedDate = Date.now
    @State var title = ""
    @State var selectedWeekDay = Dictionary(uniqueKeysWithValues: WeekDay.allCases.map { ($0, false)})
    @State var cardZipList = [CardZip]()
    @State var selectedCardZip: CardZip?
    
    @Binding var savedReminder: Reminder?
}

// MARK: - UI Components
extension AddReminderView {
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    Divider()
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            TitleInputView()
                                .padding(.horizontal, 16)
                            
                            DateInputView(proxy)
                                .padding(.horizontal, 16)
                            
                            CardZipSelectView(proxy)
                        }
                        .padding(.vertical, 16)
                    }
                    
                    Spacer()
                    
                    SaveButton(proxy)
                }
            }
            .interactiveDismissDisabled()
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShow = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationTitle("암기 리마인더 설정")
            .navigationBarTitleDisplayMode(.inline)
            
            .onAppear {
                if let currentUser = AuthManager.shared.getCurrentUser() {
                    let mIdx = currentUser.id
                    
                    DBManager.shared.fetchAllDocumentsWhereField(.card, type: CardZip.self, field: ("mIdx", mIdx)) { result in
                        switch result {
                        case .success(let _cardZipList):
                            guard let _cardZipList = _cardZipList else {
                                return
                            }
                            cardZipList = _cardZipList.compactMap { $0 }
                        case .failure(let error):
                            print("ERROR : \(error.localizedDescription)")
                        }
                    }
                }
                
            }
        }
    }
    
    private func TitleInputView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("알림 제목")
                .font(.system(size: 16, weight: .medium))
            
            TextField("알림 제목을 입력하세요...", text: $title)
                .frame(height: 40)
                .font(.system(size: 20, weight: .semibold))
                .padding(.horizontal, 8)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray.opacity(0.3), lineWidth: 1.0)
                }
        }
    }
    
    private func DateInputView(_ geometryProxy: GeometryProxy) -> some View {
        let weekDayButtonSize = (geometryProxy.size.width - 80) / 7
        
        return VStack(spacing: 10) {
            DatePicker(
                selection: $selectedDate,
                displayedComponents: [.hourAndMinute]
            ) {
                Text("알림 시간")
                    .font(.system(size: 16, weight: .medium))
            }
            .datePickerStyle(.compact)
            
            HStack {
                ForEach((0..<7)) { i in
                    if let weekDay = WeekDay(rawValue: i) {
                        Button {
                            if let selected = selectedWeekDay[weekDay] {
                                selectedWeekDay[weekDay] = !selected
                            }
                        } label: {
                            if let selected = selectedWeekDay[weekDay], selected {
                                Text("\(weekDay.text)")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: weekDayButtonSize, height: weekDayButtonSize)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(.orange, lineWidth: 1.0)
                                    }
                            } else {
                                Text("\(weekDay.text)")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: weekDayButtonSize, height: weekDayButtonSize)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(.gray.opacity(0.3), lineWidth: 1.0)
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func CardZipSelectView(_ geometryProxy: GeometryProxy) -> some View {
        let cardWidth = (geometryProxy.size.width - 40) / 2
        let cardHeight = cardWidth * 0.7
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .bottom, spacing: 8) {
                Text("암기 카드 선택")
                    .font(.system(size: 16, weight: .medium))
                
                Text("알림을 누르면 카드로 이동해요")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(cardZipList, id: \.id) { cardZip in
                        Button {
                            selectedCardZip = selectedCardZip != cardZip ? cardZip : nil
                        } label: {
                            CardZipCell(cardZip: cardZip, borderColor: selectedCardZip == cardZip ? .systemOrange : nil)
                                .frame(width: cardWidth, height: cardHeight)
                                .padding(.leading, cardZip == cardZipList.first ? 16 : 0)
                                .padding(.trailing, cardZip == cardZipList.last ? 16 : 0)
                        }
                    }
                }
            }
        }
    }
    
    private func SaveButton(_ geometryProxy: GeometryProxy) -> some View {
        let buttonWidth = geometryProxy.size.width - 32
        let buttonHeight: CGFloat = 48
        
        return Button {
            let weekDayList = selectedWeekDay.filter { $0.value }.map { $0.key }
            
            savedReminder = Reminder(
                id: UUID(),
                title: title,
                date: selectedDate,
                weekDayList: weekDayList,
                cardZipID: selectedCardZip?.id,
                isOn: true
            )
            
            isShow = false
        } label: {
            Text("저장하기")
                .frame(width: buttonWidth, height: buttonHeight)
                .background(.orange)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding(.bottom, 16)
    }
}
