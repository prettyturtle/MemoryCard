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
    
    /// 수정 버튼
    private lazy var editButton = UIButton().then {
        $0.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        $0.tintColor = .systemBlue
        $0.addTarget(
            self,
            action: #selector(didTapEditButton),
            for: .touchUpInside
        )
    }
    
    /// 삭제 버튼
    private lazy var deleteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "trash"), for: .normal)
        $0.tintColor = .systemRed
        $0.addTarget(
            self,
            action: #selector(didTapEditButton),
            for: .touchUpInside
        )
    }
    
    // MARK: ========================= </ UI 컴포넌트 > =========================
    
    
    // MARK: ========================= < 프로퍼티 > =========================
    
    var cardZip: CardZip? // 카드 집
    
    weak var delegate: CardListCollectionViewCellDelegate? // 델리게이트
    
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

// MARK: - UI 이벤트
private extension CardListCollectionViewCell {
    @objc func didTapEditButton(_ sender: UIButton) {
        guard let cardZip = cardZip else {
            return
        }
        
        switch sender {
        case editButton:
            delegate?.didTapEditButton(cardZip)
        case deleteButton:
            delegate?.didTapDeleteButton(cardZip)
        default:
            return
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
    func setupLayout(isEdit: Bool) {
        layer.cornerRadius = 12.0
        layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        layer.borderWidth = 1.0
        
        [
            cardFolderNameLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        cardFolderNameLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(Constant.defaultInset)
        }
        
        if isEdit { // 편집 모드 UI
            [
                cardCountLabel
            ].forEach {
                $0.removeFromSuperview() // 기존 UI 제거
            }
            
            [
                editButton,
                deleteButton
            ].forEach {
                contentView.addSubview($0) // 편집 모드 UI 추가
            }
            
            deleteButton.snp.makeConstraints {
                $0.top.equalTo(contentView.snp.centerY).offset(Constant.defaultInset)
                $0.trailing.bottom.equalToSuperview().inset(Constant.defaultInset)
            }
            editButton.snp.makeConstraints {
                $0.top.equalTo(contentView.snp.centerY).offset(Constant.defaultInset)
                $0.trailing.equalTo(deleteButton.snp.leading).inset(-Constant.defaultInset / 2.0)
                $0.bottom.equalToSuperview().inset(Constant.defaultInset)
            }
        } else { // 일반 모드 UI
            [
                editButton,
                deleteButton
            ].forEach {
                $0.removeFromSuperview()  // 기존 UI 제거
            }
            
            [
                cardCountLabel
            ].forEach {
                contentView.addSubview($0) // 일반 모드 UI 추가
            }
            
            cardCountLabel.snp.makeConstraints {
                $0.trailing.bottom.equalToSuperview().inset(Constant.defaultInset)
            }
        }
    }
}

import SwiftUI

struct CardZipCell: UIViewRepresentable {
    
    let cardZip: CardZip
    var borderColor: UIColor?
    
    func updateUIView(_ uiView: CardListCollectionViewCell, context: Context) {
        if let borderColor = borderColor {
            uiView.layer.borderColor = borderColor.cgColor
        } else {
            uiView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        }
    }
    
    func makeUIView(context: Context) -> CardListCollectionViewCell {
        let cell = CardListCollectionViewCell()
        
        cell.setupLayout(isEdit: false)
        cell.cardZip = cardZip
        cell.setupView()
        
        return cell
    }
}

