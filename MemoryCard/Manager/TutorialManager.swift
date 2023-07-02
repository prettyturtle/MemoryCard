//
//  TutorialManager.swift
//  MemoryCard
//
//  Created by yc on 2023/07/02.
//

import UIKit
import SnapKit
import Then
import EasyTipView

final class TutorialManager {
    static let shared = TutorialManager()
    
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
