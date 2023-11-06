//
//  GameQuizViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/11/04.
//

import UIKit
import SnapKit
import Then

final class GameQuizViewController: UIViewController {
    
    private let cardZip: CardZip
    private let gameModeOptions: [GameModeOption: Int]
    private let gameQuizCardZip: GameQuizCardZip
    
    private var currentStep = 0
    
    init(cardZip: CardZip, gameModeOptions: [GameModeOption : Int]) {
        self.cardZip = cardZip
        self.gameModeOptions = gameModeOptions
        self.gameQuizCardZip = GameQuizCardZip.createGameQuizCardZip(
            originCardZip: cardZip,
            options: gameModeOptions
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var gameQuizView = GameQuizView().then {
        $0.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupLayout()
        
        gameQuizView.gameQuizCard = gameQuizCardZip.cards.first
        
        gameQuizView.setupView()
    }
    
    private func setupLayout() {
        view.addSubview(gameQuizView)
        
        gameQuizView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension GameQuizViewController: GameQuizViewDelegate {
    func gameQuizView(_ gqv: GameQuizView, didTapSunjiButton sunjiButton: UIButton) {
        currentStep += 1
        
        if currentStep < gameQuizCardZip.cards.count {
            gqv.gameQuizCard = gameQuizCardZip.cards[currentStep]
            gqv.setupView()
        }
    }
}
