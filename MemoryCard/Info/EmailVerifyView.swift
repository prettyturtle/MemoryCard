//
//  EmailVerifyView.swift
//  MemoryCard
//
//  Created by yc on 2023/07/24.
//

import SwiftUI
import SimpleToast

struct EmailVerifyView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var showToast = false
    @State var toastMessage = "다시 시도해주세요!"
    @State var isSendMailSuccess = false
    @State var toastIcon = ""
    @State var toastBackgroundColor = Color.orange
    private let toastOptions = SimpleToastOptions(
        alignment: .top,
        hideAfter: 3,
        animation: .easeInOut
    )
    
    @Binding var isVerifiedEmail: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(spacing: 0) {
                if let email = AuthManager.shared.getCurrentUser()?.email {
                    Text("\"" + email + "\"")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 32)
                        .padding(.horizontal, 16)
                        .lineLimit(nil)
                }
                
                if isSendMailSuccess {
                    Text("로 인증 메일을 전송했습니다.\n메일 인증 후 아래 버튼을 눌러 인증을 완료하세요.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                } else {
                    Text("로 인증 메일을 전송합니다.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                }
                
                Spacer()
                
                Image(systemName: "envelope")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: UIScreen.main.bounds.width / 2.0,
                        height: UIScreen.main.bounds.width / 2.0
                    )
                    .foregroundColor(.secondary.opacity(0.6))
                
                Spacer()
            }
            
            Spacer()
            
            if isSendMailSuccess {
                VerifyEndButton()
            } else {
                VerifyButton()
            }
        }
        .navigationTitle("이메일 인증")
        
        .simpleToast(isPresented: $showToast, options: toastOptions) {
            Label(toastMessage, systemImage: toastIcon )
                .padding(.vertical, 8)
                .font(.system(size: 16, weight: .medium))
                .frame(width: UIScreen.main.bounds.width - 32)
                .background(toastBackgroundColor)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 8)
        }
    }
}

extension EmailVerifyView {
    private func VerifyButton() -> some View {
        let buttonWidth = UIScreen.main.bounds.width - 32
        let buttonHeight: CGFloat = 48
        
        return Button {
            didTapVerifyButton()
        } label: {
            Text("이메일 인증하기")
                .frame(width: buttonWidth, height: buttonHeight)
                .background(.orange)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding(.bottom, 16)
    }
    
    private func VerifyEndButton() -> some View {
        let buttonWidth = UIScreen.main.bounds.width - 32
        let buttonHeight: CGFloat = 48
        
        return Button {
            didTapVerifyEndButton()
        } label: {
            Text("인증 완료하기")
                .frame(width: buttonWidth, height: buttonHeight)
                .background(.cyan)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding(.bottom, 16)
    }
}

extension EmailVerifyView {
    private func didTapVerifyButton() {
        Task {
            do {
                try await AuthManager.shared.verifyEmail()
                
                toastMessage = "인증 메일을 전송했어요!"
                isSendMailSuccess = true
                toastIcon = "envelope.circle"
                toastBackgroundColor = .orange.opacity(0.8)
                showToast = true
                
            } catch {
                toastMessage = "다시 시도해주세요!"
                toastIcon = "exclamationmark.triangle"
                toastBackgroundColor = .pink.opacity(0.8)
                isSendMailSuccess = false
                showToast = true
            }
        }
    }
    
    private func didTapVerifyEndButton() {
        Task {
            let verifiedStatus = try await AuthManager.shared.isVerifiedEmail()
            
            if verifiedStatus {
                toastMessage = "인증이 완료됐어요!"
                toastIcon = "checkmark.circle"
                toastBackgroundColor = .cyan.opacity(0.8)
                showToast = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isVerifiedEmail = verifiedStatus
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                toastMessage = "인증에 실패했어요!"
                toastIcon = "exclamationmark.triangle"
                toastBackgroundColor = .pink.opacity(0.8)
                showToast = true
            }
        }
    }
}
