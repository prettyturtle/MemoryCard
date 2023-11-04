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
    private let gameQuizCardZip: CardZip
    
    init(cardZip: CardZip, gameModeOptions: [GameModeOption : Int]) {
        self.cardZip = cardZip
        self.gameModeOptions = gameModeOptions
        
        var gameModeCards = cardZip.cards
        
        if gameModeOptions[.sort] == 1 {
            gameModeCards = gameModeCards.reversed()
        } else if gameModeOptions[.sort] == 2 {
            gameModeCards = gameModeCards.shuffled()
        }
        
        if gameModeOptions[.state] == 1 {
            for i in 0..<gameModeCards.count {
                var gameModeCard = gameModeCards[i]
                
                let temp = gameModeCard.front
                gameModeCard.front = gameModeCard.back
                gameModeCard.back = temp
                
                gameModeCards[i] = gameModeCard
            }
        } else if gameModeOptions[.state] == 2 {
            for i in 0..<gameModeCards.count {
                let random = [true, false].randomElement()!
                
                if !random { continue }
                
                var gameModeCard = gameModeCards[i]
                
                let temp = gameModeCard.front
                gameModeCard.front = gameModeCard.back
                gameModeCard.back = temp
                
                gameModeCards[i] = gameModeCard
            }
        }
        
        self.gameQuizCardZip = CardZip(
            folderName: cardZip.folderName,
            cards: gameModeCards,
            mIdx: cardZip.mIdx
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        print("=========")
        print(cardZip)
        print("---------")
        print(gameQuizCardZip)
        print("=========")
    }
}

struct GameQuizCardZip {
    var id: String = UUID().uuidString
    var originID: String
    var cards: [GameQuizCard]
    var mIdx: String
    
    struct GameQuizCard {
        var target: String
        var answer: String
        var id: Int
        var originID: Int
        var sunjis: [String]
    }
    
    static func createGameQuizCardZip(
        originCardZip: CardZip,
        options: [GameModeOption: Int]
    ) {
        
    }
}
