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
