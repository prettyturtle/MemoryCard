//
//  GameFeedbackCardDetailViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/11/12.
//

import UIKit
import SnapKit
import Then

final class GameFeedbackCardDetailViewController: UIViewController {
    let feedbackCard: Card
    
    private lazy var cardCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
    }
    
    private lazy var cardCollectionView = UICollectionView(frame: .zero, collectionViewLayout: cardCollectionViewFlowLayout).then {
        $0.register(
            CardStudyCollectionViewCell.self,
            forCellWithReuseIdentifier: CardStudyCollectionViewCell.identifier
        )
        $0.dataSource = self
        $0.delegate = self
    }
    
    init(feedbackCard: Card) {
        self.feedbackCard = feedbackCard
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
    
    @objc func didTapDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension GameFeedbackCardDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardStudyCollectionViewCell.identifier,
            for: indexPath
        ) as? CardStudyCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.card = feedbackCard
        cell.setupLayout()
        cell.setupView()
        
        return cell
    }
}

extension GameFeedbackCardDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - CGFloat(Constant.defaultInset * 2)
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = CGFloat(Constant.defaultInset)
        return UIEdgeInsets(top: 0.0, left: edgeInset, bottom: 0.0, right: edgeInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardStudyCollectionViewCell else {
            return
        }
        
        cell.rotateCard()
    }
}

extension GameFeedbackCardDetailViewController {
    /// 내비게이션 바 설정
    func setupNavigationBar() {
        navigationItem.addDismissButton(self, action: #selector(didTapDismissButton))
    }
    
    /// 레이아웃 설정
    func setupLayout() {
        [
            cardCollectionView
        ].forEach {
            view.addSubview($0)
        }
        
        cardCollectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
