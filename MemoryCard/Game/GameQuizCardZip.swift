//
//  GameQuizCardZip.swift
//  MemoryCard
//
//  Created by yc on 2023/11/05.
//

import Foundation

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
        var isFront: Bool
        var isCorrect: Bool? = nil
    }
    
    static func createGameQuizCardZip(
        originCardZip: CardZip,
        options: [GameModeOption: Int]
    ) -> GameQuizCardZip {
        var gameQuizCardZip = GameQuizCardZip(
            originID: originCardZip.id,
            cards: [],
            mIdx: originCardZip.mIdx
        )
        
        var originCards = originCardZip.cards
        
        if options[.sort] == 1 {
            originCards = originCards.reversed()
        } else if options[.sort] == 2 {
            originCards = originCards.shuffled()
        }
        
        for i in 0..<originCards.count {
            let gameQuizCard = GameQuizCard(
                target: originCards[i].front.content,
                answer: originCards[i].back.content,
                id: i,
                originID: originCards[i].id,
                sunjis: [],
                isFront: true
            )
            
            gameQuizCardZip.cards.append(gameQuizCard)
        }
        
        if options[.state] == 1 {
            for i in 0..<gameQuizCardZip.cards.count {
                var gameQuizCard = gameQuizCardZip.cards[i]
                gameQuizCard.isFront = false
                
                let temp = gameQuizCard.target
                gameQuizCard.target = gameQuizCard.answer
                gameQuizCard.answer = temp
                
                gameQuizCardZip.cards[i] = gameQuizCard
            }
        } else if options[.state] == 2 {
            for i in 0..<gameQuizCardZip.cards.count {
                let random = [true, false].randomElement()!
                
                if !random { continue }
                
                var gameQuizCard = gameQuizCardZip.cards[i]
                gameQuizCard.isFront = false
                
                let temp = gameQuizCard.target
                gameQuizCard.target = gameQuizCard.answer
                gameQuizCard.answer = temp
                
                gameQuizCardZip.cards[i] = gameQuizCard
            }
        }
        
        for i in 0..<gameQuizCardZip.cards.count {
            let gameQuizCard = gameQuizCardZip.cards[i]
            
            guard let answerCard = originCards.filter({ $0.id == gameQuizCard.originID }).first else {
                fatalError("말도 안돼")
            }
            
            let answer = gameQuizCard.isFront ? answerCard.back.content : answerCard.front.content
            
            var sunjis = [answer]
            
            var noAnswerCards = originCards.filter({ $0.id != gameQuizCard.originID })
            
            var sunjisLimit = 2
            
            if !noAnswerCards.isEmpty {
                if options[.sunjiCount] == 1 {
                    sunjisLimit = 3
                } else if options[.sunjiCount] == 2 {
                    sunjisLimit = 4
                }
                
                while sunjis.count < sunjisLimit {
                    let randomCard = noAnswerCards.randomElement()!
                    
                    let sunji = gameQuizCard.isFront ? randomCard.back.content : randomCard.front.content
                    
                    sunjis.append(sunji)
                    
                    noAnswerCards = noAnswerCards.filter { $0.id != randomCard.id }
                    
                    if noAnswerCards.isEmpty {
                        break
                    }
                }
            }
            
            gameQuizCardZip.cards[i].sunjis = sunjis
        }
        
        return gameQuizCardZip
    }
}
