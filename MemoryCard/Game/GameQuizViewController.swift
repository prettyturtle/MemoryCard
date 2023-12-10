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
    private var gameQuizCardZip: GameQuizCardZip
    
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
        
        setupNavigationBar()
        setupLayout()
        
        gameQuizView.gameQuizCard = gameQuizCardZip.cards.first
        
        gameQuizView.setupView()
    }
    
    @objc func didTapSkipButton(_ sender: UIBarButtonItem) {
        gameQuizView.skip()
    }
    
    private func setupNavigationBar() {
        if gameModeOptions[.skip] == 0 {
            let skipBarButtonItem = UIBarButtonItem(
                title: "SKIP",
                style: .plain,
                target: self,
                action: #selector(didTapSkipButton)
            )
            navigationItem.setRightBarButton(skipBarButtonItem, animated: true)
        }
    }
    
    private func setupLayout() {
        view.addSubview(gameQuizView)
        
        gameQuizView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension GameQuizViewController: GameQuizViewDelegate {
    func gameQuizView(_ gqv: GameQuizView, didTapSunjiButton sunjiButton: UIButton, isCorrect: Bool) {
        gameQuizCardZip.cards[currentStep].isCorrect = isCorrect
        
        currentStep += 1
        
        if currentStep < gameQuizCardZip.cards.count {
            gqv.gameQuizCard = gameQuizCardZip.cards[currentStep]
            gqv.setupView()
        } else {
            guard let currentUser = AuthManager.shared.getCurrentUser() else {
                return
            }
            
            let mIdx = currentUser.id
            
            DBManager.shared.save(.gameFeedback, documentName: mIdx, data: gameQuizCardZip) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else {
                        return
                    }
                    
                    let vc = GameFeedbackViewController(feedback: self.gameQuizCardZip)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func gameQuizView(_ gqv: GameQuizView, didSkip: Void) {
        gameQuizCardZip.cards[currentStep].isCorrect = nil
        
        currentStep += 1
        
        if currentStep < gameQuizCardZip.cards.count {
            gqv.gameQuizCard = gameQuizCardZip.cards[currentStep]
            gqv.setupView()
        } else {
            guard let currentUser = AuthManager.shared.getCurrentUser() else {
                return
            }
            
            let mIdx = currentUser.id
            
            DBManager.shared.save(
                .gameFeedback,
                documentName: gameQuizCardZip.id,
                data: gameQuizCardZip,
                completion: { _ in }
            )
                
            DispatchQueue.main.async {
                let vc = GameFeedbackViewController(feedback: self.gameQuizCardZip)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func gameQuizView(_ gqv: GameQuizView, didLongPressSunjiButton: UIButton, target card: Card) {
        let gameFeedbackCardDetailVC = GameFeedbackCardDetailViewController(feedbackCard: card)
        
        let gameFeedbackCardDetailNC = UINavigationController(rootViewController: gameFeedbackCardDetailVC)
        gameFeedbackCardDetailNC.modalPresentationStyle = .overFullScreen
        gameFeedbackCardDetailNC.modalTransitionStyle = .crossDissolve
        
        present(gameFeedbackCardDetailNC, animated: true)
    }
}
