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
    
    private lazy var dismissButton = OpacityButton().then {
        $0.setTitle(nil, for: .normal)
        $0.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        $0.imageView?.tintColor = .secondaryLabel
        $0.backgroundColor = .secondarySystemFill
        $0.layer.cornerRadius = 30
        $0.addTarget(
            self,
            action: #selector(didTapDismissButton),
            for: .touchUpInside
        )
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
    func setupLayout() {
        [
            cardCollectionView,
            dismissButton
        ].forEach {
            view.addSubview($0)
        }
        
        cardCollectionView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        dismissButton.snp.makeConstraints {
            $0.size.equalTo(60)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(cardCollectionView.snp.bottom).offset(Constant.defaultInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
        }
    }
}
