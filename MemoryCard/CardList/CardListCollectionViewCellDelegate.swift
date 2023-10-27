//
//  CardListCollectionViewCellDelegate.swift
//  MemoryCard
//
//  Created by yc on 2023/05/15.
//

import Foundation

/// 홈 카드 리스트 셀 관련 델리게이트
protocol CardListCollectionViewCellDelegate: AnyObject {
    
    /// 편집 버튼을 눌렀을 때
    /// - Parameter cardZip: 편집할 카드집
    func didTapEditButton(_ cardZip: CardZip)
    
    /// 삭제 버튼을 눌렀을 때
    /// - Parameter cardZip: 삭제할 카드집
    func didTapDeleteButton(_ cardZip: CardZip)
    
    /// 게임 모드 버튼을 눌렀을 때
    /// - Parameter cardZip: 게임할 카드집
    func didTapGameModeButton(_ cardZip: CardZip)
}
