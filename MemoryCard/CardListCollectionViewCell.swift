//
//  CardListCollectionViewCell.swift
//  MemoryCard
//
//  Created by yc on 2023/04/09.
//

import UIKit
import SnapKit
import Then

final class CardListCollectionViewCell: UICollectionViewCell {
    static let identifier = "CardListCollectionViewCell"
    
    // MARK: ========================= < UI 컴포넌트 > =========================
    
    /// 카드 집 이름 라벨
    private lazy var cardFolderNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18.0, weight: .medium)
        $0.numberOfLines = 2
    }
    
    /// 카드 개수 라벨
    private lazy var cardCountLabel = UILabel().then {
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 14.0, weight: .medium)
    }
    
    // MARK: ========================= </ UI 컴포넌트 > =========================
    
    
    // MARK: ========================= < 프로퍼티 > =========================
    
    var cardZip: CardZip? // 카드 집
    
    // MARK: ========================= </ 프로퍼티 > ========================
}

// MARK: - 재정의
extension CardListCollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            // Highlighted 상태일 때, 살짝 줄어드는 애니메이션
            UIView.animate(withDuration: 0.05) {
                if self.isHighlighted {
                    self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)   // 사이즈 줄이기
                } else {
                    self.transform = .identity                                  // 사이즈 복구
                }
            }
        }
    }
}

// MARK: - 로직
extension CardListCollectionViewCell {
    /// 데이터 UI 적용
    func setupView() {
        guard let cardZip = cardZip else {
            return
        }
        
        cardFolderNameLabel.text = cardZip.folderName   // 카드 집 이름 설정
        cardCountLabel.text = "\(cardZip.cards.count)장" // 카드 개수 설정
    }
}

// MARK: - UI 레이아웃
extension CardListCollectionViewCell {
    /// 레이아웃 설정
    func setupLayout() {
        layer.cornerRadius = 12.0
        layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 0.4
        
        [
            cardFolderNameLabel,
            cardCountLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        cardFolderNameLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(Constant.defaultInset)
        }
        cardCountLabel.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(Constant.defaultInset)
        }
    }
}
