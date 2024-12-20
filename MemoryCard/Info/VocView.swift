//
//  VocView.swift
//  MemoryCard
//
//  Created by yc on 2023/10/15.
//

import SwiftUI
import SimpleToast

struct VocView: View {
	
	@Binding var isShowVocView: Bool
	@Binding var user: User
	
	@State private var title = ""
	
	@State private var description = "메모리카드를 더 좋게 만들기 위한 아이디어를 제안하거나 문제를 알려주세요! 어떤 개선사항이나 문제를 발견하셨나요? 아래 양식을 통해 간단한 제목과 자세한 설명을 공유해주세요. 제보사항을 신속하게 검토하고 빠른 시일 내에 문제를 해결해드릴 것을 약속드립니다 🙇‍♀️"
	
	@State private var placeholderText = "자세한 설명을 입력하세요..."
	@State private var content = ""
	
	@State private var isShowDismissAlert = false
	@State private var canSubmitVoc = false
	
	@State var showToast = false
	@State var toastMessage = "다시 시도해주세요!"
	private let toastOptions = SimpleToastOptions(hideAfter: 3, animation: .easeInOut)
	
	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				Divider()
				
				ScrollView {
					VStack(spacing: 16) {
						Text(description)
							.foregroundColor(.secondary)
							.font(UIFont.Pretendard.r14.font)
						
						VStack(alignment: .leading, spacing: 10) {
							Text("제목")
								.font(UIFont.Pretendard.m16.font)
							
							TextField("제목을 입력하세요...", text: $title)
								.frame(height: 40)
								.font(UIFont.Pretendard.m20.font)
								.padding(.horizontal, 8)
								.overlay {
									RoundedRectangle(cornerRadius: 10)
										.stroke(.gray.opacity(0.3), lineWidth: 1.0)
								}
						}
						
						VStack(alignment: .leading, spacing: 10) {
							Text("설명")
								.font(UIFont.Pretendard.m16.font)
							
							ZStack {
								if content.isEmpty {
									TextEditor(text: $placeholderText)
										.font(UIFont.Pretendard.r16.font)
										.foregroundColor(.gray)
										.disabled(true)
										.frame(height: 300)
								}
								TextEditor(text: $content)
									.font(UIFont.Pretendard.r16.font)
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
			.onChange(of: title, perform: { _ in
				canSubmitVoc = !title.isEmpty || !content.isEmpty
			})
			.onChange(of: content, perform: { _ in
				canSubmitVoc = !title.isEmpty || !content.isEmpty
			})
			
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
					NavigationLink {
						VocListView(user: $user)
					} label: {
						Image(systemName: "clock.arrow.2.circlepath")
					}
				}
				
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						// TODO: - 개선 요청 제출
						IndicatorManager.shared.start()
						
						let voc = Voc(
							mIdx: user.id,
							title: title,
							content: content,
							createdDate: .now
						)
						
						if canSubmitVoc {
							DBManager.shared.save(
								.voc,
								documentName: voc.id,
								data: voc
							) { result in
								IndicatorManager.shared.stop()
								switch result {
								case .success(_):
									print("성공!")
									isShowVocView = false
								case .failure(let error):
									showToast = true
									print("😫", error.localizedDescription)
								}
							}
						}
					} label: {
						Text("보내기")
					}
					.disabled(!canSubmitVoc)
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
			.simpleToast(isPresented: $showToast, options: toastOptions) {
				Label(toastMessage, systemImage: "exclamationmark.triangle")
					.padding(.vertical, 8)
					.font(UIFont.Pretendard.m16.font)
					.frame(width: UIScreen.main.bounds.width - 32)
					.background(.pink.opacity(0.8))
					.foregroundColor(.white)
					.cornerRadius(10)
					.padding(.top, 8)
			}
		}
	}
}

//struct VocDetailView: View {
//	let voc: Voc
//
//	var body: some View {
//		VStack(alignment: .leading, spacing: 0) {
//			Divider()
//
//			ScrollView {
//				VStack(spacing: 16) {
//					VStack(alignment: .leading, spacing: 10) {
//						Text("제목")
//							.font(UIFont.Pretendard.m16)
//
//						Text(voc.title)
//							.font(UIFont.Pretendard.m20.font)
//							.lineLimit(0)
//					}
//
//					Text(voc.formattedDate)
//						.foregroundColor(.secondary)
//						.font(UIFont.Pretendard.r14.font)
//
//					VStack(alignment: .leading, spacing: 10) {
//						Text("설명")
//							.font(UIFont.Pretendard.m16)
//
//						Text(voc.content)
//							.font(UIFont.Pretendard.r16.font)
//							.lineLimit(0)
//					}
//				}
//				.padding(16)
//			}
//		}
//	}
//}
