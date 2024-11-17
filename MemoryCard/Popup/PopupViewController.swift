//
//  PopupViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/08/12.
//

import UIKit
import SnapKit
import Then

protocol PopupViewDelegate: AnyObject {
    func popup(_ popupView: PopupView, isDismiss: Bool)
    func popup(_ popupView: PopupView, action: PopupAction)
}

protocol PopupView: UIView {
    var delegate: PopupViewDelegate? { get set }
}

final class PopupViewController: BaseViewController {
    let popupView: PopupView
    
    init(popupView: PopupView) {
        self.popupView = popupView
        super.init(nibName: nil, bundle: nil)
        
        self.popupView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PopupViewController: PopupViewDelegate {
    func popup(_ popupView: PopupView, isDismiss: Bool) {
        UserDefaults.standard.setValue(Date.now, forKey: IS_TAPPED_PUSH_ALLOW)
        dismiss(animated: true)
    }
    func popup(_ popupView: PopupView, action: PopupAction) {
        switch action {
        case .pushAllow:
            let notiOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                let allowStatus = settings.authorizationStatus
                
                if allowStatus == .denied {
                    var settingsURLString = UIApplication.openSettingsURLString
                    
                    if #available(iOS 16.0, *) {
                        settingsURLString = UIApplication.openNotificationSettingsURLString
                    } else if #available(iOS 15.4, *) {
                        settingsURLString = UIApplicationOpenNotificationSettingsURLString
                    }
                    
                    guard let settingsURL = URL(string: settingsURLString) else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.open(settingsURL)
                        self?.dismiss(animated: true)
                    }
                } else {
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: notiOptions,
                        completionHandler: { _, _ in
                            UserDefaults.standard.setValue(Date.now, forKey: IS_TAPPED_PUSH_ALLOW)
                            
                            DispatchQueue.main.async {
                                self?.dismiss(animated: true)
                            }
                        }
                    )
                }
            }
        }
    }
}

extension PopupViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray.withAlphaComponent(0.3)
        
        setupLayout()
    }
}

extension PopupViewController {
    func setupLayout() {
        view.addSubview(popupView)
        popupView.layer.cornerRadius = 24.0
        
        popupView.snp.makeConstraints {
            if Constant.deviceType == .phone {
                $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
                $0.centerY.equalToSuperview()
            } else if Constant.deviceType == .pad {
                $0.width.equalTo(400.0)
                $0.center.equalToSuperview()
            }
        }
    }
}

