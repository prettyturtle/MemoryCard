//
//  CreateCardContentInputCollectionViewCellDelegate.swift
//  MemoryCard
//
//  Created by yc on 2023/04/02.
//

import Foundation

/// 카드 내용 입력 셀 델리게이트
protocol CreateCardContentInputCollectionViewCellDelegate: AnyObject {
    
    /// 카드 내용 입력시 호출되는 함수
    /// - Parameters:
    ///   - cell: 현재 셀
    ///   - index: 셀 인덱스
    ///   - text: 카드 내용
    ///   - type: 카드 내용 타입 (앞, 뒤)
    func createCardContentInputCollectionViewCell(
        didChangeContentText cell: CreateCardContentInputCollectionViewCell,
        index: Int,
        text: String,
        type: CardContentType
    )
}
