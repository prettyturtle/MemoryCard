//
//  ShopView.swift
//  MemoryCard
//
//  Created by yc on 2023/12/05.
//

import SwiftUI

struct ShopView: View {
    
    @Binding var isShow: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    HStack {
                        Image(systemName: "sdcard")
                            .resizable()
                            .scaledToFit()
                            .padding(32)
                            .foregroundStyle(.cyan)
                            .frame(height: 300)
                            .rotationEffect(.radians(-.pi / 6.0))
                        Spacer()
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Spacer()
                            .frame(width: 100)
                        Image(systemName: "sdcard")
                            .resizable()
                            .scaledToFit()
                            .padding(32)
                            .foregroundStyle(.orange)
                            .frame(height: 300)
                            .rotationEffect(.radians(.pi / 6.0))
                    }
                }
                
                Button {
                    
                } label: {
                    
                    HStack {
                        Spacer()
                        Text("Card+5")
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12.0)
                            .stroke(.gray.opacity(0.3), lineWidth: 1.0)
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
            .navigationTitle("이용권 구매")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShow = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Text("구매 복원")
                    }
                }
            }
        }
    }
}
