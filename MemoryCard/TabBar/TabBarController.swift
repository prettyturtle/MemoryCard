//
//  TabBarController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SwiftUI
import Toast

final class TabBarController: UITabBarController {
	
	private let homeVC = UINavigationController(rootViewController: MyCardListViewController())
	private let createCardTempVC = UIViewController()
	private let myInfoVC = UIHostingController(rootView: MyInfoView())
	
	private lazy var homeVCTabBarItem = UITabBarItem(
		title: "카드리스트",
		image: UIImage(systemName: "list.bullet"),
		selectedImage: nil
	).then { $0.tag = 0 }
	
	private lazy var createCardVCTabBarItem = UITabBarItem(
		title: "카드만들기",
		image: UIImage(systemName: "plus.circle"),
		selectedImage: nil
	).then { $0.tag = 1 }
	
	private lazy var myInfoVCTabBarItem = UITabBarItem(
		title: "설정",
		image: UIImage(systemName: "gearshape"),
		selectedImage: nil
	).then { $0.tag = 2 }
	
	private func setupTabBarItem() {
		homeVC.tabBarItem = homeVCTabBarItem
		createCardTempVC.tabBarItem = createCardVCTabBarItem
		myInfoVC.tabBarItem = myInfoVCTabBarItem
	}
}

// MARK: - Life Cycle
extension TabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTabBarItem()
		
		tabBar.backgroundColor = .secondarySystemBackground
		
		viewControllers = [
			homeVC,
			createCardTempVC,
			myInfoVC
		]
		
		delegate = self
		
		NotificationCenter
			.default
			.addObserver(
				self,
				selector: #selector(didTapTutorialDimView),
				name: .TUTORIAL_DID_TAP_DIM_VIEW,
				object: nil
			)
		
		NotificationCenter
			.default
			.addObserver(
				self,
				selector: #selector(didReceivePush),
				name: .DID_RECEIVE_PUSH,
				object: nil
			)
		
		if let appVersion = Constant.appVersion {
			DBManager.shared
				.fetchDocument(
					.util,
					documentName: "UpdateVersion",
					type: UpdateVersion.self
				) { [weak self] result in
					guard let self = self else {
						return
					}
					
					switch result {
					case .success(let updateVersion):
						let version = updateVersion.version
						let storeURL = updateVersion.storeURL
						
						let alertTitle = updateVersion.alertTitle
						let alertMessage = updateVersion.alertMessage
						
						if version > appVersion {
							
							let updateAlert = Alert(style: .alert)
								.setTitle(alertTitle)
								.setMessage(alertMessage)
								.setAction(title: "확인", style: .default) { _ in
									if let url = URL(string: storeURL),
									   UIApplication.shared.canOpenURL(url) {
										UIApplication.shared.open(url, options: [:]) { _ in
											exit(0)
										}
									} else {
										exit(0)
									}
								}
								.endSet()
							
							present(updateAlert, animated: true)
						}
						
					case .failure(_):
						fatalError("버전 체크 에러 (2)")
					}
				}
		} else {
			fatalError("버전 체크 에러 (1)")
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let isDoneTutorialIntro = UserDefaults.standard.bool(forKey: IS_DONE_TUTORIAL_INTRO)
		if !isDoneTutorialIntro {
			TutorialManager.shared.show(
				at: self,
				id: 0,
				for: createCardVCTabBarItem,
				text: "안녕하세요! 메모리마스터입니다 🙋",
				arrowPosition: .bottom
			)
		}
	}
}

// MARK: - UI 이벤트
extension TabBarController {
	/// 푸시를 눌러서 들어왔을 때 카드 열기
	@objc func didReceivePush(_ notification: Notification) {
		guard let userInfo = notification.userInfo as? [String: String],
			  let cardZipID = userInfo["cardZipID"] else {
			return
		}
		
		if cardZipID != "" {
			DBManager.shared.fetchDocument(.card, documentName: cardZipID, type: CardZip.self) { [weak self] result in
				guard let self = self else {
					return
				}
				
				if case .success(let cardZip) = result {
					let rootVC = CardStudyViewController(cardZip: cardZip)
					let cardStudyVC = UINavigationController(rootViewController: rootVC)
					
					cardStudyVC.modalPresentationStyle = .fullScreen
					
					self.present(cardStudyVC, animated: true)
				}
			}
		}
	}
	
	@objc func didTapTutorialDimView(_ notification: Notification) {
		guard let userInfo = notification.userInfo as? [String: Int],
			  let tutorialID = userInfo["id"] else {
			return
		}
		
		print(tutorialID, "🎉")
		
		let nextID = tutorialID + 1
		
		if tutorialID == 0 {
			TutorialManager.shared.show(
				at: self,
				id: nextID,
				for: createCardVCTabBarItem,
				text: "지금부터 메모리마스터를 소개해드릴게요 🙇‍♀️",
				arrowPosition: .bottom
			)
		} else if tutorialID == 4 {
			TutorialManager.shared.show(
				at: self,
				id: nextID,
				for: createCardVCTabBarItem,
				text: "카드는 만들고 싶으면 여기를 눌러주세요 👻",
				arrowPosition: .bottom
			)
		}
	}
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
	func tabBarController(
		_ tabBarController: UITabBarController,
		shouldSelect viewController: UIViewController
	) -> Bool {
		if tabBarController.tabBar.selectedItem?.tag == 1 {
			
			guard let currentUser = AuthManager.shared.getCurrentUser() else {
				return false
			}
			
			let mIdx = currentUser.id
			
			if !AuthManager.shared.isVerifiedEmail() {
				view.makeToast("[설정]에서 이메일을 인증해주세요!", duration: 2) { [weak self] _ in
					self?.selectedIndex = 2
				}
				
				return false
			}
			
			IndicatorManager.shared.start()
			
			DBManager.shared.fetchAllDocumentsWhereField(
				.card,
				type: CardZip.self,
				field: ("mIdx", mIdx)
			) { [weak self] result in
				
				IndicatorManager.shared.stop()
				
				let rootVC = CreateCardFolderNameInputViewController()
				
				switch result {
				case .success(let cardZipList):
					if let cardZipList = cardZipList,
					   cardZipList.count >= 5,
					   mIdx != "LWtgt6ntq3d13PDWp45ZWcISQ2u1" {
						self?.view.makeToast("카드는 최대 5개까지 생성할 수 있어요.")
					} else {
						let createCardVC = UINavigationController(rootViewController: rootVC)
						
						createCardVC.modalPresentationStyle = .fullScreen
						self?.present(createCardVC, animated: true)
					}
				case .failure(let error):
					print("🤢 ERROR \(error.localizedDescription)")
					
					let createCardVC = UINavigationController(rootViewController: rootVC)
					
					createCardVC.modalPresentationStyle = .fullScreen
					self?.present(createCardVC, animated: true)
				}
			}
			
			return false
		} else {
			return true
		}
	}
}
