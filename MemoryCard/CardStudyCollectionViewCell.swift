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
        $0.font = .systemFont(ofSize: 32.0, weight: .bold)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    
    var card: Card?
    
    func setupView() {
        cardContentLabel.text = card?.front.content
    }
    
    func setupLayout() {
        layer.cornerRadius = 12.0
        layer.borderColor = UIColor.separator.cgColor
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
