//
//  UINavigationItem+.swift
//  MemoryCard
//
//  Created by yc on 2023/04/15.
//

import UIKit

extension UINavigationItem {
    
    /// 나가기 버튼 추가 함수
    /// - Parameters:
    ///   - target: 추가할 타겟
    ///   - action: 탭 이벤트
    func addDismissButton(_ target: Any?, action: Selector?) {
        self.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: target,
            action: action
        )
    }
}
