//
//  HomeViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SnapKit
import Then
import FirebaseAuth

// MARK: - 홈 뷰컨
final class HomeViewController: UIViewController {
    
    // MARK: ========================= < UI 컴포넌트 > =========================
    /// 카드 생성 라벨
    private lazy var createCardLabel = UILabel().then {
        $0.text = "동해물과백...\n두산이? 마르고닳 도록하느"
        $0.font = .systemFont(ofSize: 22.0, weight: .bold)
        $0.numberOfLines = 2
    }
    
    /// 카드 생성 버튼
    private lazy var createCardButton = OpacityButton().then {
        $0.setTitle("암기 카드 만들기", for: .normal)
        $0.style = .fill(backgroundColor: .systemOrange)
        $0.addTarget(
            self,
            action: #selector(didTapCreateCardButton),
            for: .touchUpInside
        )
    }
    
    /// 나의 카드 미리보기 리스트
    private lazy var myCardListPreviewLabel = UILabel().then {
        $0.text = "나의 카드"
        $0.font = .systemFont(ofSize: 18.0, weight: .semibold)
    }
    
    /// 나의 카드 더보기 버튼
    private lazy var myCardListPreviewMoreButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .label
        $0.addTarget(
            self,
            action: #selector(didTapMyCardListPreviewMoreButton),
            for: .touchUpInside
        )
    }
    
    /// 나의 카드 미리보기 콜랙션 뷰 레이아웃
    private lazy var homeMyCardListPreviewCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
    }
    
    /// 나의 카드 미리보기 콜랙션 뷰
    private lazy var homeMyCardListPreviewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: homeMyCardListPreviewCollectionViewFlowLayout).then {
        $0.alwaysBounceHorizontal = true
        $0.showsHorizontalScrollIndicator = false
        $0.register(
            CardListCollectionViewCell.self,
            forCellWithReuseIdentifier: CardListCollectionViewCell.identifier
        )
        $0.dataSource = self
        $0.delegate = self
    }
    // MARK: ========================= </ UI 컴포넌트 > =========================
    
    
    // MARK: ========================= < 프로퍼티 > =========================
    
    private var cardZipList = [CardZip]() // 카드 집 리스트
    
    // MARK: ========================= </ 프로퍼티 > ========================

}

// MARK: - 라이프 사이클
extension HomeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // 배경색 설정
        
        setupNavigationBar()    // 내비게이션 설정
        setupLayout()           // 레이아웃 설정
        
        
        fetchCardZip()          // 카드 집 불러오기
    }
}

private extension HomeViewController {
    
    /// 카드 집 불러오는 함수
    ///
    /// 카드 집을 fetch 하고 콜렉션 뷰를 reload 한다
    func fetchCardZip() {
        // DB에서 카드 집 불러오기 시작
        DBManager.shared.fetchDocuments(.card, type: CardZip.self) { [weak self] result in
            // DB에서 카드 집 불러오기 완료
            guard let self = self else { return }
            
            switch result {
            case .success(let cardZip):                         // 불러오기 성공시
                self.cardZipList.append(cardZip)                // 카드 집 리스트에 추가
                
                self.reloadMyCardListPreviewCollectionView()    // 콜렉션 뷰 새로고침
            case .failure(let error):                           // 불러오기 실패시
                print("💩 ERROR : \(error.localizedDescription)")
            }
        }
    }
    
    /// 나의 카드 집 콜렉션 뷰 새로고침 함수
    func reloadMyCardListPreviewCollectionView() {
        DispatchQueue.main.async {
            self.homeMyCardListPreviewCollectionView.reloadData() // 새로고침
        }
    }
}

// MARK: - UI 이벤트
private extension HomeViewController {
    
    /// 카드 생성 버튼을 눌렀을 때
    /// - Parameter sender: 카드 생성 버튼
    @objc func didTapCreateCardButton(_ sender: UIButton) {
        let createCardIntroVC = CreateCardIntroViewController()                                 // 카드 생성 뷰컨
        let createCardIntroNVC = UINavigationController(rootViewController: createCardIntroVC)  // 카드 생성 NVC
        
        createCardIntroNVC.modalPresentationStyle = .fullScreen                                 // 풀스크린
        present(createCardIntroNVC, animated: true)                                             // 카드 뷰컨 띄우기
    }
    
    /// 나의 카드 더보기 버튼을 눌렀을 때
    /// - Parameter sender: 나의 카드 더보기 버튼
    @objc func didTapMyCardListPreviewMoreButton(_ sender: UIButton) {
        // TODO: - 나의 카드 더보기 버튼 구현
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - CGFloat(Constant.defaultInset * 3)) / 2.0 // 셀 너비
        let height = collectionView.frame.height                                            // 셀 높이
        return CGSize(width: width, height: height)                                         // 셀 사이즈
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = CGFloat(Constant.defaultInset)                                  // 셀 모서리 여백
        return UIEdgeInsets(top: 0.0, left: edgeInset, bottom: 0.0, right: edgeInset)   // 죄우 여백
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(Constant.defaultInset / 2.0)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardZipList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardListCollectionViewCell.identifier,
            for: indexPath
        ) as? CardListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setupLayout()
        cell.cardZip = cardZipList[indexPath.item]
        cell.setupView()
        
        return cell
    }
}

// MARK: - UI 레이아웃
private extension HomeViewController {
    
    /// 내비게이션 바 설정
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "star"),
            style: .plain,
            target: self,
            action: nil
        )
    }
    
    /// 레이아웃 설정
    func setupLayout() {
        [
            createCardLabel,
            createCardButton,
            myCardListPreviewLabel,
            myCardListPreviewMoreButton,
            homeMyCardListPreviewCollectionView
        ].forEach {
            view.addSubview($0)
        }
        
        createCardLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
        }
        createCardButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(createCardLabel.snp.bottom).offset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
        myCardListPreviewLabel.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(createCardButton.snp.bottom).offset(Constant.defaultInset * 2)
        }
        myCardListPreviewMoreButton.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.bottom.equalTo(myCardListPreviewLabel)
        }
        homeMyCardListPreviewCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(myCardListPreviewLabel.snp.bottom).offset(Constant.defaultInset)
            $0.height.equalTo(120.0)
        }
    }
}
