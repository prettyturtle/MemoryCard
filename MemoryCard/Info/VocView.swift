//
//  VocView.swift
//  MemoryCard
//
//  Created by yc on 2023/10/15.
//

import SwiftUI

struct VocView: View {
    
    @Binding var isShowVocView: Bool
    @Binding var user: User
    
    @State private var title = ""
    
    @State private var description = "메모리카드를 더 좋게 만들기 위한 아이디어를 제안하거나 문제를 알려주세요! 어떤 개선사항이나 문제를 발견하셨나요? 아래 양식을 통해 간단한 제목과 자세한 설명을 공유해주세요. 제보사항을 신속하게 검토하고 빠른 시일 내에 문제를 해결해드릴 것을 약속드립니다 🙇‍♀️"
    
    @State private var placeholderText = "자세한 설명을 입력하세요..."
    @State private var content = ""
    
    @State private var isShowDismissAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text(description)
                            .foregroundColor(.secondary)
                            .font(.system(size: 14, weight: .regular))
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("제목")
                                .font(.system(size: 16, weight: .medium))
                            
                            TextField("제목을 입력하세요...", text: $title)
                                .frame(height: 40)
                                .font(.system(size: 20, weight: .semibold))
                                .padding(.horizontal, 8)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.gray.opacity(0.3), lineWidth: 1.0)
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("설명")
                                .font(.system(size: 16, weight: .medium))
                            
                            ZStack {
                                if content.isEmpty {
                                    TextEditor(text: $placeholderText)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.gray)
                                        .disabled(true)
                                        .frame(height: 300)
                                }
                                TextEditor(text: $content)
                                    .font(.system(size: 16, weight: .regular))
                                    .opacity(content.isEmpty ? 0.25 : 1)
                                    .frame(height: 300)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.gray.opacity(0.3), lineWidth: 1.0)
                                    }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .interactiveDismissDisabled()
            
            .navigationTitle("개선 요청")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if !title.isEmpty || !content.isEmpty {
                            isShowDismissAlert = true
                        } else {
                            isShowVocView = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO: - 개선 요청 제출
                        let voc = Voc(
                            mIdx: user.id,
                            title: title,
                            content: content,
                            createdDate: .now
                        )
                        
                        isShowVocView = false
                    } label: {
                        Text("보내기")
                    }
                }
            }
            .alert("작성중인 내용이 있습니다.\n나가시겠습니까?", isPresented: $isShowDismissAlert) {
                Button(role: .destructive) {
                    isShowVocView = false
                } label: {
                    Text("나가기")
                }
                
                Button(role: .cancel) {
                    
                } label: {
                    Text("취소")
                }
            } message: {
                Text("작성된 내용은 저장되지 않습니다.")
            }
        }
    }
}

struct Voc: Codable, Identifiable {
    var id: String = UUID().uuidString
    let mIdx: String
    let title: String
    let content: String
    let createdDate: Date
}
