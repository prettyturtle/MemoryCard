//
//  GameFeedbackViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/11/08.
//

import UIKit
import SnapKit
import Then
import Lottie

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
    
    private lazy var congratulationLottieAnimationView = LottieAnimationView(name: "congratulation").then {
        $0.loopMode = .playOnce
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
        
        setupNavigationBar()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        congratulationLottieAnimationView.play()
    }
    
    @objc func didTapDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc func didTapStarButton(_ sender: UIBarButtonItem) {
        sender.image = sender.image == UIImage(systemName: "star") ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
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

extension GameFeedbackViewController {
    private func setupNavigationBar() {
        navigationItem.addDismissButton(self, action: #selector(didTapDismissButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "star"),
            style: .plain,
            target: self,
            action: #selector(didTapStarButton)
        )
    }
    
    private func setupLayout() {
        [
            feedbackTableView,
            congratulationLottieAnimationView
        ].forEach {
            view.addSubview($0)
        }
        
        feedbackTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        congratulationLottieAnimationView.snp.makeConstraints {
            $0.size.equalTo(view.safeAreaLayoutGuide).dividedBy(2)
            $0.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
