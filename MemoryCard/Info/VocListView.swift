//
//  VocListView.swift
//  MemoryCard
//
//  Created by yc on 2023/10/16.
//

import SwiftUI

struct VocListView: View {
    
    @State private var vocList = [Voc]()
    @Binding var user: User
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(vocList) { vocItem in
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(vocItem.title)
										.font(UIFont.Pretendard.m18.font)
                                        .lineLimit(0)
                                    
                                    Text(vocItem.content)
										.font(UIFont.Pretendard.r16.font)
                                        .foregroundColor(.secondary)
                                        .lineLimit(0)
                                    
                                    Text(vocItem.formattedDate)
                                        .foregroundColor(.secondary)
										.font(UIFont.Pretendard.r14.font)
                                }
                                .padding(16)
                                
                                Spacer()
                            }
                            
                            Divider()
                        }
                    }
                }
            }
        }
        .onAppear {
            DBManager.shared.fetchAllDocumentsWhereField(.voc, type: Voc.self, field: ("mIdx", user.id)) { result in
                switch result {
                case .success(let fetchedVocList):
                    vocList = (fetchedVocList ?? []).compactMap { $0 }
                case .failure(_):
                    vocList = []
                }
            }
        }
    }
}
