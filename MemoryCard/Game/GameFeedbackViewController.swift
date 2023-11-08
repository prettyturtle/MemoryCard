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
            UITableViewCell.self,
            forCellReuseIdentifier: "CELL"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        
        cell.textLabel?.text = feedback.cards[indexPath.row].target
        
        return cell
    }
}
