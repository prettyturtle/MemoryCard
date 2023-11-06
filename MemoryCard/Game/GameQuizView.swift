//
//  GameQuizView.swift
//  MemoryCard
//
//  Created by yc on 2023/11/05.
//

import UIKit
import SnapKit
import Then

protocol GameQuizViewDelegate: AnyObject {
    func gameQuizView(_ gqv: GameQuizView, didTapSunjiButton sunjiButton: UIButton)
}

final class GameQuizView: UIView {
    
    var gameQuizCard: GameQuizCardZip.GameQuizCard?
    weak var delegate: GameQuizViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var targetCardView = UIView().then {
        $0.layer.cornerRadius = 12.0
        $0.layer.borderColor = UIColor.systemOrange.cgColor
        $0.layer.borderWidth = 1.0
    }
    
    private lazy var cardContentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 32.0, weight: .bold)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    
    private lazy var sunjiListStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
    }
    
    func setupView() {
        sunjiListStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        guard let gameQuizCard = gameQuizCard else {
            return
        }
        
        cardContentLabel.text = gameQuizCard.target
        
        for sunji in gameQuizCard.sunjis.shuffled() {
            let sunjiButton = UIButton().then {
                $0.setTitle(sunji, for: .normal)
                $0.setTitleColor(.label, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
                $0.layer.cornerRadius = 12
                $0.layer.borderWidth = 0.4
                $0.layer.borderColor = UIColor.darkGray.cgColor
                $0.addTarget(
                    self,
                    action: #selector(didTapSunjiButton),
                    for: .touchUpInside
                )
            }
            
            sunjiButton.snp.makeConstraints {
                $0.height.equalTo(50)
            }
            
            sunjiListStackView.addArrangedSubview(sunjiButton)
        }
    }
    
    @objc func didTapSunjiButton(_ sender: UIButton) {
        sender.isEnabled = false
        
        guard let sunji = sender.titleLabel?.text else {
            return
        }
        
        sender.backgroundColor = gameQuizCard?.answer == sunji ? .systemGreen : .systemRed
        sender.setTitleColor(.white, for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.delegate?.gameQuizView(self, didTapSunjiButton: sender)
        }
    }
    
    private func setupLayout() {
        [
            targetCardView,
            sunjiListStackView
        ].forEach {
            addSubview($0)
        }
        
        targetCardView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(Constant.defaultInset)
        }
        
        sunjiListStackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(Constant.defaultInset)
            $0.top.equalTo(targetCardView.snp.bottom).offset(Constant.defaultInset * 2)
        }
        
        [
            cardContentLabel
        ].forEach {
            targetCardView.addSubview($0)
        }
        
        cardContentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constant.defaultInset)
        }
    }
}
