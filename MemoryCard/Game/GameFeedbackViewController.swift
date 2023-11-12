//
//  GameFeedbackViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/11/08.
//

import UIKit
import SnapKit
import Then

final class GameFeedbackViewController: UIViewController {
    
    private let feedback: GameQuizCardZip
    
    private lazy var feedbackTableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(
            GameFeedbackTableViewCell.self,
            forCellReuseIdentifier: GameFeedbackTableViewCell.identifier
        )
    }
    
    init(feedback: GameQuizCardZip) {
        self.feedback = feedback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupLayout()
    }
    
    private func setupLayout() {
        [
            feedbackTableView
        ].forEach {
            view.addSubview($0)
        }
        
        feedbackTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension GameFeedbackViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedback.cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: GameFeedbackTableViewCell.identifier,
            for: indexPath
        ) as? GameFeedbackTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setupView(gameQuizCard: feedback.cards[indexPath.row])
        
        return cell
    }
}

extension GameFeedbackViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let gameQuizCard = feedback.cards[indexPath.row]
        
        let feedbackCard = Card(
            id: gameQuizCard.originID,
            front: Card.CardContent(content: gameQuizCard.target),
            back: Card.CardContent(content: gameQuizCard.answer)
        )
        
        let gameFeedbackCardDetailVC = GameFeedbackCardDetailViewController(feedbackCard: feedbackCard)
        
        let gameFeedbackCardDetailNC = UINavigationController(rootViewController: gameFeedbackCardDetailVC)
        gameFeedbackCardDetailNC.modalPresentationStyle = .overFullScreen
        gameFeedbackCardDetailNC.modalTransitionStyle = .crossDissolve
        
        present(gameFeedbackCardDetailNC, animated: true)
    }
}
