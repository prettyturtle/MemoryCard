//
//  StudyModeConfigView.swift
//  MemoryCard
//
//  Created by yc on 2023/06/03.
//

import SwiftUI

struct StudyModeConfigView: View {
    
    @State var cardStartState: CardContentType = .front
    
    var body: some View {
        List {
            Section {
                
                Button {
                    cardStartState = .front
                    
                    UserDefaults.standard.setValue("front", forKey: "CARD_START_STATE")
                } label: {
                    
                    HStack {
                        Text("앞 부터")
                            .foregroundColor(cardStartState == .front ? .gray : .black)
                        
                        Spacer()
                        
                        Text("✓")
                            .foregroundColor(.gray)
                            .opacity(cardStartState == .front ? 1.0 : 0.0)
                    }
                }
                
                Button {
                    cardStartState = .back
                    
                    UserDefaults.standard.setValue("back", forKey: "CARD_START_STATE")
                } label: {
                    Text("뒤 부터")
                        .foregroundColor(cardStartState == .back ? .gray : .black)
                    
                    Spacer()
                    
                    Text("✓")
                        .foregroundColor(.gray)
                        .opacity(cardStartState == .back ? 1.0 : 0.0)
                }
                
            } header: {
                Text("카드 시작은")
            }
            .buttonStyle(.borderless)
            .padding(.vertical, 16.0)
            
            .listRowInsets(
                EdgeInsets(
                    top: 0,
                    leading: 16.0,
                    bottom: 0,
                    trailing: 16.0
                )
            )
        }
        .onAppear {
            if let savedCardStartState = UserDefaults.standard.string(forKey: "CARD_START_STATE") {
                cardStartState = savedCardStartState == "front" ? .front : .back
            } else {
                cardStartState = .front
            }
        }
    }
}

struct StudyModeConfigView_Previews: PreviewProvider {
    static var previews: some View {
        StudyModeConfigView()
    }
}
