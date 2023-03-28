//
//  IndicatorManager.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SnapKit

final class IndicatorManager {
    static let shared = IndicatorManager()
    
    private init() {}
    
    private lazy var indicatorView = UIActivityIndicatorView()
    
    func start() {
        if let currentVC = UIApplication.topViewController() {
            currentVC.view.addSubview(indicatorView)
            indicatorView.snp.makeConstraints {
                $0.center.equalTo(currentVC.view.safeAreaLayoutGuide)
            }
            
            indicatorView.startAnimating()
        }
    }
    
    func stop() {
        indicatorView.stopAnimating()
        indicatorView.removeFromSuperview()
    }
}
