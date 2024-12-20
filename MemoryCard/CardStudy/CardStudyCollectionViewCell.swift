//
//  CardStudyCollectionViewCell.swift
//  MemoryCard
//
//  Created by yc on 2023/04/16.
//

import UIKit
import SnapKit
import Then

final class CardStudyCollectionViewCell: UICollectionViewCell {
    static let identifier = "CardStudyCollectionViewCell"
    
    private lazy var cardContentLabel = UILabel().then {
        $0.font = .Pretendard.b32
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    
    var card: Card?
    var cardContentType: CardContentType = .front
    
    func rotateCard() {
        var animationOption: UIView.AnimationOptions
        
        switch cardContentType {
        case .front:
            cardContentLabel.text = card?.back.content
            cardContentType = .back
            animationOption = .transitionFlipFromRight
        case .back:
            cardContentLabel.text = card?.front.content
            cardContentType = .front
            animationOption = .transitionFlipFromLeft
        }
        
        UIView.transition(
            with: self,
            duration: 0.3,
            options: animationOption,
            animations: nil
        )
    }
    
    func setupView() {
        if let savedCardStartState = UserDefaults.standard.string(forKey: CARD_START_STATE) {
            if savedCardStartState == "front" {
                cardContentType = .front
                cardContentLabel.text = card?.front.content
            } else {
                cardContentType = .back
                cardContentLabel.text = card?.back.content
            }
        } else {
            cardContentType = .front
            cardContentLabel.text = card?.front.content
        }
    }
    
    func setupLayout() {
        layer.cornerRadius = 12.0
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 0.4
        
        [
            cardContentLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        cardContentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constant.defaultInset)
        }
    }
}
