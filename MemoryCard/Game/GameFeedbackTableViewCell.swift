//
//  GameFeedbackTableViewCell.swift
//  MemoryCard
//
//  Created by yc on 2023/11/12.
//

import UIKit
import SnapKit
import Then

final class GameFeedbackTableViewCell: UITableViewCell {
    static let identifier = "GameFeedbackTableViewCell"
    
    private lazy var targetLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = .label
    }
    private lazy var answerLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .secondaryLabel
    }
    private lazy var correctImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(gameQuizCard: GameQuizCardZip.GameQuizCard) {
        let target = gameQuizCard.target
        let answer = gameQuizCard.answer
        let isCorrect = gameQuizCard.isCorrect
        
        targetLabel.text = target
        answerLabel.text = answer
        
        if let isCorrect = isCorrect {
            let correctImage = isCorrect ? "circle" : "xmark"
            let correctImageColor = isCorrect ? UIColor.systemGreen : UIColor.systemRed
            
            correctImageView.image = UIImage(systemName: correctImage)
            correctImageView.tintColor = correctImageColor
        } else {
            let correctImage = "triangle"
            let correctImageColor = UIColor.systemOrange
            
            correctImageView.image = UIImage(systemName: correctImage)
            correctImageView.tintColor = correctImageColor
        }
    }
    
    private func setupLayout() {
        [
            targetLabel,
            answerLabel,
            correctImageView
        ].forEach {
            contentView.addSubview($0)
        }
        
        targetLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(Constant.defaultInset)
        }
        
        answerLabel.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(targetLabel.snp.bottom).offset(Constant.defaultInset)
            $0.trailing.equalTo(targetLabel.snp.trailing)
        }
        
        correctImageView.snp.makeConstraints {
            $0.size.equalTo(36)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(targetLabel.snp.trailing).offset(Constant.defaultInset)
            $0.trailing.equalToSuperview().inset(Constant.defaultInset)
        }
    }
}
