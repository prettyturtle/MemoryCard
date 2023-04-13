//
//  MyCardListViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/04/11.
//

import UIKit
import SnapKit
import Then

// MARK: - 나의 카드 리스트 뷰컨
final class MyCardListViewController: UIViewController {
    
    // MARK: ========================= < UI 컴포넌트 > =========================
    
    /// 리프레시 컨트롤
    private lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(
            self,
            action: #selector(beginRefresh),
            for: .valueChanged
        )
    }
    
    /// 나의 카드 미리보기 콜랙션 뷰 레이아웃
    private lazy var homeMyCardListPreviewCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
    }
    
    /// 나의 카드 미리보기 콜랙션 뷰
    private lazy var homeMyCardListPreviewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: homeMyCardListPreviewCollectionViewFlowLayout).then {
        $0.refreshControl = refreshControl
        $0.alwaysBounceVertical = true
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
    
    var cardZipList: [CardZip] // 카드 집 리스트
    
    // MARK: ========================= </ 프로퍼티 > ========================
    
    // MARK: ========================= < init > =========================
    init(cardZipList: [CardZip]) {
        self.cardZipList = cardZipList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: ========================= </ init > ========================
}

// MARK: - 라이프 사이클
extension MyCardListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // 배경색 설정
        
        setupNavigationBar()    // 내비게이션 설정
        setupLayout()           // 레이아웃 설정
    }
}

private extension MyCardListViewController {
    
    /// 카드 집 불러오는 함수
    ///
    /// 카드 집을 fetch 하고 콜렉션 뷰를 reload 한다
    ///
    /// - Parameter completion: 완료 컴플리션
    func fetchCardZip(completion: (() -> Void)? = nil) {
        guard let currentUser = AuthManager.shared.getCurrentUser() else { // 현재 유저
            return  // TODO: - 현재 유저가 없을 때 예외처리
        }
        
        let mIdx = currentUser.uid                              // 유저 mIdx
        
        // DB에서 카드 집 불러오기 시작
        DBManager.shared.fetchDocumentsWhereField(
            .card,
            type: CardZip.self,
            field: ("mIdx", mIdx)
        ) { [weak self] result in
            // DB에서 카드 집 불러오기 완료
            guard let self = self else { return }
            
            switch result {
            case .success(let cardZip):                         // 불러오기 성공시
                if let cardZip = cardZip {
                    self.cardZipList.append(cardZip)                // 카드 집 리스트에 추가
                }
            case .failure(let error):                           // 불러오기 실패시
                print("💩 ERROR : \(error.localizedDescription)")
            }
            
            self.reloadMyCardListPreviewCollectionView()    // 콜렉션 뷰 새로고침
            
            completion?()                                       // 완료
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
private extension MyCardListViewController {
    
    /// 리프레시 컨트롤 시작 함수
    /// - Parameter sender: 리프레시 컨트롤
    @objc func beginRefresh(_ sender: UIRefreshControl) {
        cardZipList = [] // 현재 카드 집 비우기
        
        // 카드 집 불러오기 시작
        fetchCardZip {
            // 카드 집 불러오기 완료
            sender.endRefreshing() // 리프레시 컨트롤 종료
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyCardListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - CGFloat(Constant.defaultInset * 3)) / 2.0 // 셀 너비
        let height = 120.0                                            // 셀 높이
        return CGSize(width: width, height: height)                                         // 셀 사이즈
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = CGFloat(Constant.defaultInset)                                  // 셀 모서리 여백
        return UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)   // 죄우 여백
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(Constant.defaultInset / 2.0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        // 셀이 눌렸을 때, 살짝 줄어들었다가 다시 돌아오는 애니메이션
        UIView.animate(withDuration: 0.05, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)   // 사이즈 줄이기
        }, completion: { _ in
            UIView.animate(withDuration: 0.05, animations: {
                cell.transform = CGAffineTransform.identity             // 사이즈 복구
            })
        })
    }
}

// MARK: - UICollectionViewDataSource
extension MyCardListViewController: UICollectionViewDataSource {
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
private extension MyCardListViewController {
    
    /// 내비게이션 바 설정
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "나의 카드"
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    /// 레이아웃 설정
    func setupLayout() {
        [
            homeMyCardListPreviewCollectionView
        ].forEach {
            view.addSubview($0)
        }
        
        homeMyCardListPreviewCollectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
