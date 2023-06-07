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
    
    @State private var userEmail = ""
    @State private var cardZipCount = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0.0) {
                Divider()
                
                ProfileView(
                    userEmail: $userEmail,
                    cardZipCount: $cardZipCount
                )
                
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
        .onAppear {
            guard let currentUser = AuthManager.shared.getCurrentUser() else {
                return
            }
            
            let mIdx = currentUser.uid
            
            userEmail = currentUser.email ?? "..."
            
            DBManager.shared.fetchAllDocumentsWhereField(
                .card,
                type: CardZip.self,
                field: ("mIdx", mIdx)
            ) { result in
                switch result {
                case .success(let cardZipList):
                    guard let cardZipList = cardZipList else {
                        return
                    }
                    
                    self.cardZipCount = cardZipList.count
                case .failure(let error):
                    print("👩🏻‍🦳ERROR \(error.localizedDescription)")
                }
            }
        }
    }
}

struct MyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MyInfoView()
    }
}
