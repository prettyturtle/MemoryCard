//
//  TabBarController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SwiftUI
import EasyTipView

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
    
    private var tipView: EasyTipView?
    
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didTapTutorialDimView),
            name: NSNotification.Name("TUTORIAL_DID_TAP_DIM_VIEW"),
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isDoneTutorialIntro = UserDefaults.standard.bool(forKey: "IS_DONE_TUTORIAL_INTRO")
        if !isDoneTutorialIntro {
            TutorialToolTip.shared.show(
                at: self,
                id: 0,
                for: createCardVCTabBarItem,
                text: "안녕하세요! 메모리마스터입니다 🙋",
                arrowPosition: .bottom
            )
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
            TutorialToolTip.shared.show(
                at: self,
                id: nextID,
                for: createCardVCTabBarItem,
                text: "지금부터 메모리마스터를 소개해드릴게요 🙇‍♀️",
                arrowPosition: .bottom
            )
        } else if tutorialID == 4 {
            TutorialToolTip.shared.show(
                at: self,
                id: nextID,
                for: createCardVCTabBarItem,
                text: "카드는 만들고 싶으면 여기를 눌러주세요 👻",
                arrowPosition: .bottom
            )
        }
    }
    
    private func setupTabBarItem() {
        homeVC.tabBarItem = homeVCTabBarItem
        createCardTempVC.tabBarItem = createCardVCTabBarItem
        myInfoVC.tabBarItem = myInfoVCTabBarItem
    }
}

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
                       cardZipList.count >= 5 {
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

import SnapKit
import Then

final class TutorialToolTip {
    static let shared = TutorialToolTip()
    
    private lazy var dimView = UIView().then {
        $0.backgroundColor = .darkGray.withAlphaComponent(0.3)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(didTapDimView))
        
        $0.addGestureRecognizer(tapGesture)
    }
    
    private var tipView: EasyTipView?
    private var currentID: Int = -1
    
    private lazy var preference: EasyTipView.Preferences = {
        var p = EasyTipView.Preferences()
        p.drawing.font = .systemFont(ofSize: 16.0, weight: .medium)
        p.drawing.foregroundColor = .white
        p.drawing.backgroundColor = .systemOrange
        p.drawing.arrowPosition = .bottom
        p.animating.dismissOnTap = false
        p.positioning.maxWidth = UIScreen.main.bounds.width - 32.0
        return p
    }()
    
    @objc private func didTapDimView() {
        dismiss(step: .dim)
        NotificationCenter.default.post(
            name: NSNotification.Name("TUTORIAL_DID_TAP_DIM_VIEW"),
            object: nil,
            userInfo: ["id": currentID]
        )
    }
    
    func show(
        at target: UIViewController,
        id: Int,
        for view: UIView,
        text: String,
        arrowPosition: EasyTipView.ArrowPosition
    ) {
        currentID = id
        
        target.view.addSubview(dimView)
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        preference.drawing.arrowPosition = arrowPosition
        
        tipView = EasyTipView(text: text, preferences: preference)
        
        tipView?.show(forView: view)
    }
    
    func show(
        at target: UIViewController,
        id: Int,
        for item: UIBarItem,
        text: String,
        arrowPosition: EasyTipView.ArrowPosition
    ) {
        currentID = id
        
        target.view.addSubview(dimView)
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        preference.drawing.arrowPosition = arrowPosition
        
        tipView = EasyTipView(text: text, preferences: preference)
        
        tipView?.show(forItem: item)
    }
    
    func dismiss(step: TutorialDismissStep) {
        switch step {
        case .tip:
            tipView?.dismiss()
        case .dim:
            tipView?.dismiss()
            dimView.removeFromSuperview()
        }
    }
    
    enum TutorialDismissStep {
        case tip
        case dim
    }
}
