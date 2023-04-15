//
//  CardStudyViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/04/15.
//

import UIKit
import SnapKit
import Then

// MARK: - 카드 공부 뷰컨
final class CardStudyViewController: UIViewController {
    
    // MARK: ========================= < UI 컴포넌트 > =========================
    
    private lazy var cardStudyCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
    }
    private lazy var cardStudyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: cardStudyCollectionViewFlowLayout).then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.register(
            CardStudyCollectionViewCell.self,
            forCellWithReuseIdentifier: CardStudyCollectionViewCell.identifier
        )
        $0.dataSource = self
        $0.delegate = self
    }
    
    private lazy var pageControlView = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
    }
    
    // MARK: ========================= </ UI 컴포넌트 > ========================
    
    
    // MARK: ========================= < 프로퍼티 > =========================
    
    private let cardZip: CardZip
    
    // MARK: ========================= </ 프로퍼티 > ========================
    
    
    // MARK: ========================= < init > =========================
    
    init(cardZip: CardZip) {
        self.cardZip = cardZip
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ========================= </ init > ========================
}

// MARK: - 라이프 사이클
extension CardStudyViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground    // 배경색 설정
        setupNavigationBar()                        // 내비게이션 설정
        setupLayout()                               // 레이아웃 설정
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CardStudyViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - CGFloat(Constant.defaultInset * 2)
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = CGFloat(Constant.defaultInset)
        return UIEdgeInsets(top: 0.0, left: edgeInset, bottom: 0.0, right: edgeInset)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(Constant.defaultInset * 2)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardStudyCollectionViewCell else { return }
        
        // 셀이 눌렸을 때, 살짝 줄어들었다가 다시 돌아오는 애니메이션
        UIView.animate(withDuration: 0.05, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)   // 사이즈 줄이기
        }, completion: { _ in
            UIView.animate(withDuration: 0.05, animations: {
                cell.transform = CGAffineTransform.identity             // 사이즈 복구
            })
        })
        
        cell.rotateCard()
    }
}

// MARK: - UICollectionViewDataSource
extension CardStudyViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardZip.cards.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardStudyCollectionViewCell.identifier,
            for: indexPath
        ) as? CardStudyCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.card = cardZip.cards[indexPath.item]
        cell.cardContentType = .front
        cell.setupLayout()
        cell.setupView()
        
        return cell
    }
}

// MARK: - UI 이벤트
private extension CardStudyViewController {
    @objc func didTapDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - UI 레이아웃
private extension CardStudyViewController {
    
    /// 내비게이션 바 설정
    func setupNavigationBar() {
        navigationItem.title = cardZip.folderName
        navigationItem.addDismissButton(self, action: #selector(didTapDismissButton))
    }
    
    /// 레이아웃 설정
    func setupLayout() {
        [
            cardStudyCollectionView,
            pageControlView
        ].forEach {
            view.addSubview($0)
        }
        
        cardStudyCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        pageControlView.snp.makeConstraints {
            $0.top.equalTo(cardStudyCollectionView.snp.bottom).offset(Constant.defaultInset)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(120.0)
        }
    }
}
