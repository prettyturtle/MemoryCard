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
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                let weekDayButtonSize = (proxy.size.width - 80) / 7
                
                VStack(spacing: 0) {
                    Divider()
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            
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
                            
                            VStack(spacing: 10) {
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
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .bottom, spacing: 8) {
                                    Text("암기 카드 선택")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text("알림을 누르면 카드로 이동해요")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                                
                                ScrollView(.horizontal) {
                                    LazyHStack {
                                        ForEach(cardZipList, id: \.id) { cardZip in
                                            Text(cardZip.folderName)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            
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
}

//struct AddReminderView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddReminderView()
//    }
//}
