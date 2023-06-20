//
//  MyInfoView.swift
//  MemoryCard
//
//  Created by yc on 2023/04/25.
//

import SwiftUI

struct MyInfoView: View {
    
    @State private var isShowLogoutAlert = false
    @State private var isShowDeleteUserAlert = false
    
    @State private var currentUser = User(id: "", email: "")
    @State private var cardZipCount = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0.0) {
                Divider()
                
                ProfileView(
                    currentUser: $currentUser,
                    cardZipCount: $cardZipCount
                )
                
                Divider()
                
                List {
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
                    
                    Button {
                        isShowLogoutAlert = true
                    } label: {
                        MyInfoViewCell(
                            title: "로그아웃",
                            textColor: .blue
                        )
                    }
                    
                    Button {
                        isShowDeleteUserAlert = true
                    } label: {
                        MyInfoViewCell(
                            title: "회원탈퇴",
                            textColor: .red
                        )
                    }
                }
                .listStyle(.plain)
            }
            
            
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("회원탈퇴", isPresented: $isShowDeleteUserAlert) {
            Button(role: .destructive) {
                delete()
            } label: {
                Text("탈퇴하기")
            }
            
            Button(role: .cancel) {
                
            } label: {
                Text("취소")
            }
        } message: {
            Text("정말로 탈퇴하시겠습니까?\n탈퇴 시 모든 데이터가 삭제되고\n복구할 수 없습니다.")
        }
        .alert("로그아웃", isPresented: $isShowLogoutAlert) {
            Button(role: .destructive) {
                logout()
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
            getCardZipCount()
        }
    }
}

private extension MyInfoView {
    /// 회원탈퇴
    func delete() {
        AuthManager.shared.getCurrentUser { userResult in
            switch userResult {
            case .success(let user):
                let mIdx = user.id
                
                DBManager.shared.fetchAllDocumentsWhereField(
                    .card,
                    type: CardZip.self,
                    field: ("mIdx", mIdx)
                ) { dbResult in
                    switch dbResult {
                    case .success(let deletedCardZipList):
                        guard let deletedCardZipList = deletedCardZipList else {
                            return
                        }
                        
                        for deletedCardZip in deletedCardZipList {
                            guard let deletedCardZip = deletedCardZip else {
                                return
                            }
                            
                            let documentName = deletedCardZip.id
                            
                            DBManager.shared.deleteDocument(.card, documentName: documentName) { error in
                                if let error = error {
                                    print("ERROR : \(error.localizedDescription)")
                                }
                            }
                        }
                        
                        DBManager.shared.deleteDocument(.user, documentName: mIdx) { error in
                            if let error = error {
                                print("ERROR : \(error.localizedDescription)")
                            }
                        }
                        
                        AuthManager.shared.delete { result in
                            switch result {
                            case .success(_):
                                let rootVC = UINavigationController(rootViewController: LoginViewController())
                                
                                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                                
                                sceneDelegate?.changeRootViewController(rootVC, animated: true)
                            case .failure(let error):
                                print("탈퇴 실패 : \(error.localizedDescription)")
                            }
                        }
                        
                    case .failure(let error):
                        print("ERROR : \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("ERROR : \(error.localizedDescription)")
            }
        }
    }
    
    /// 로그아웃
    func logout() {
        if AuthManager.shared.logout() {
            let rootVC = UINavigationController(rootViewController: LoginViewController())
            
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            
            sceneDelegate?.changeRootViewController(rootVC, animated: true)
        }
    }
    
    /// 카드집 개수 구하기
    func getCardZipCount() {
        AuthManager.shared.getCurrentUser { result in
            switch result {
            case .success(let currentUser):
                let mIdx = currentUser.id
                
                self.currentUser = currentUser
                
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
                
            case .failure(let error):
                print("👩🏻‍🦳 ERROR \(error.localizedDescription)")
            }
        }
    }
}

struct MyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MyInfoView()
    }
}
