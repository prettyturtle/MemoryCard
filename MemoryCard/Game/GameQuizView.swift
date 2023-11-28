//
//  GameQuizView.swift
//  MemoryCard
//
//  Created by yc on 2023/11/05.
//

import UIKit
import SnapKit
import Then
import Lottie

protocol GameQuizViewDelegate: AnyObject {
    func gameQuizView(_ gqv: GameQuizView, didTapSunjiButton sunjiButton: UIButton, isCorrect: Bool)
    func gameQuizView(_ gqv: GameQuizView, didSkip: Void)
    func gameQuizView(_ gqv: GameQuizView, didLongPressSunjiButton: UIButton, target card: Card)
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
    
    private lazy var correctLottieAnimationView = LottieAnimationView(name: "correct_lottie").then {
        $0.loopMode = .playOnce
    }
    
    private lazy var wrongLottieAnimationView = LottieAnimationView(name: "wrong_lottie").then {
        $0.loopMode = .playOnce
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
                
                let longPressGesture = UILongPressGestureRecognizer(
                    target: self,
                    action: #selector(didGestureSunjiButton)
                )
                
                let tapGesture = UITapGestureRecognizer(
                    target: self,
                    action: #selector(didGestureSunjiButton)
                )
                
                $0.addGestureRecognizer(tapGesture)
                $0.addGestureRecognizer(longPressGesture)
            }
            
            sunjiButton.snp.makeConstraints {
                $0.height.equalTo(50)
            }
            
            sunjiListStackView.addArrangedSubview(sunjiButton)
        }
    }
    
    func skip() {
        delegate?.gameQuizView(self, didSkip: ())
    }
    
    private func didTapSunjiButton(_ sender: UIButton) {
        sunjiListStackView.arrangedSubviews.forEach {
            ($0 as? UIButton)?.isEnabled = false
        }
        
        guard let sunji = sender.titleLabel?.text else {
            return
        }
        
        let isCorrect = gameQuizCard?.answer == sunji
        
        sender.backgroundColor = isCorrect ? .systemGreen : .systemRed
        sender.setTitleColor(.white, for: .normal)
        
        if isCorrect {
            correctLottieAnimationView.play()
        } else {
            wrongLottieAnimationView.play()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.delegate?.gameQuizView(self, didTapSunjiButton: sender, isCorrect: isCorrect)
        }
    }
    
    @objc func didGestureSunjiButton(_ gesture: UIGestureRecognizer) {
        guard let sender = gesture.view as? UIButton else {
            return
        }
        
        if gesture is UITapGestureRecognizer {
            didTapSunjiButton(sender)
        } else if gesture is UILongPressGestureRecognizer {
            print("LONG")
            
            if gesture.state == .began {
                
                guard let sunjiText = sender.titleLabel?.text else {
                    return
                }
                
                let card = Card(
                    id: -1,
                    front: Card.CardContent(content: sunjiText),
                    back: Card.CardContent(content: sunjiText)
                )
                
                delegate?.gameQuizView(self, didLongPressSunjiButton: sender, target: card)
            }
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
            cardContentLabel,
            correctLottieAnimationView,
            wrongLottieAnimationView
        ].forEach {
            targetCardView.addSubview($0)
        }
        
        cardContentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constant.defaultInset)
        }
        
        [
            correctLottieAnimationView,
            wrongLottieAnimationView
        ].forEach { lottie in
            lottie.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalToSuperview().dividedBy(2)
                $0.height.equalTo(lottie.snp.width)
            }
        }
    }
}
