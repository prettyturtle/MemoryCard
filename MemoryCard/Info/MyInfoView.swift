//
//  MyInfoView.swift
//  MemoryCard
//
//  Created by yc on 2023/04/25.
//

import SwiftUI

struct MyInfoView: View {
    
    @State private var isShowUserInfoAlert = false
    @State private var isShowLogoutAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0.0) {
                Divider()
                
                HStack(spacing: 0.0) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60.0, height: 60.0)
                        .cornerRadius(30.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30.0)
                                .stroke(Color.secondary, lineWidth: 0.2)
                        )
                    
                    VStack(alignment: .leading, spacing: 0.0) {
                        Text(AuthManager.shared.getCurrentUser()?.email ?? "bbb@bbb.com")
                            .font(.system(size: 16.0, weight: .semibold))
                        
                        Text("카드 개수 : \(10)")
                            .padding(.top, 8.0)
                            .font(.system(size: 16.0, weight: .semibold))
                            .foregroundColor(.secondary)
                            
                    }
                    .padding(.horizontal, 16.0)
                    
                    Spacer()
                }
                .padding(16.0)
                
                Divider()
                
                List {
                    Button {
                        isShowUserInfoAlert = true
                    } label: {
                        MyInfoViewCell(
                            title: "회원정보",
                            textColor: .blue
                        )
                    }
                    
                    Button {
                        isShowLogoutAlert = true
                    } label: {
                        MyInfoViewCell(
                            title: "로그아웃",
                            textColor: .red
                        )
                    }
                    
                    ZStack {
                        NavigationLink {
                            StudyModeConfigView()
                        } label: {
                            EmptyView()
                        }
                        .opacity(0.0)
                        
                        MyInfoViewCell(
                            title: "학습모드 설정",
                            textColor: .black
                        )
                    }
                }
                .listStyle(.plain)
            }
            
            
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("회원정보", isPresented: $isShowUserInfoAlert) {
            Button("OK") {}
        } message: {
            let user = AuthManager.shared.getCurrentUser()
            
            let msg = """
                \(user?.email ?? "")
                \(user?.displayName ?? "")
                \(user?.metadata.creationDate ?? .now)
                \(user?.metadata.lastSignInDate ?? .now)
            """
            
            Text(msg)
        }
        .alert("로그아웃", isPresented: $isShowLogoutAlert) {
            Button(role: .destructive) {
                if AuthManager.shared.logout() {
                    let rootVC = UINavigationController(rootViewController: LoginViewController())
                    
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    
                    sceneDelegate?.changeRootViewController(rootVC, animated: true)
                }
            } label: {
                Text("로그아웃")
            }
            
            Button(role: .cancel) {
                print("로그아웃 취소")
            } label: {
                Text("취소")
            }
        } message: {
            Text("정말로 로그아웃 하시겠습니까?")
        }
    }
}

struct MyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MyInfoView()
    }
}
