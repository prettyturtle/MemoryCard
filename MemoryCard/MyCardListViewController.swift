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
    
    private var cardZipList = [CardZip]() // 카드 집 리스트
    private var isEdit = false // 수정중 플래그
    
    // MARK: ========================= </ 프로퍼티 > ========================
}

// MARK: - 라이프 사이클
extension MyCardListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // 배경색 설정
        
        setupNavigationBar()    // 내비게이션 설정
        setupLayout()           // 레이아웃 설정
        
        fetchCardZip()          // 카드 집 불러오기
    }
}

// MARK: - 로직
private extension MyCardListViewController {
    
    /// 카드 집 불러오는 함수
    ///
    /// 카드 집을 fetch 하고 콜렉션 뷰를 reload 한다
    ///
    /// - Parameter completion: 완료 컴플리션
    func fetchCardZip(completion: (() -> Void)? = nil) {
        IndicatorManager.shared.start() // 인디케이터 시작
        
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
            
            IndicatorManager.shared.stop() // 인디케이터 종료
            
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
    
    /// 카드집 삭제 함수
    func deleteCard(_ cardZip: CardZip) {
        DBManager.shared.deleteDocument(.card, documentName: cardZip.id) { error in
            if let error = error {
                print("💩 카드 삭제 실패 : \(error.localizedDescription)")
                return
            }
            
            self.cardZipList = []
            self.fetchCardZip()
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
    
    
    /// 편집 시작 함수
    /// - Parameter sender: 편집 바 버튼
    @objc func didTapModifyButton(_ sender: UIBarButtonItem) {
        isEdit.toggle()
        
        sender.title = isEdit ? "완료" : "편집"
        
        homeMyCardListPreviewCollectionView.refreshControl = isEdit ? nil : refreshControl
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
        
        if isEdit { // 편집 모드일 때
            // 삭제를 선택했을 때 이벤트
            let deleteHandler: (UIAlertAction) -> Void = { [weak self] _ in
                guard let self = self else {
                    return
                }
                
                // 삭제 얼럿 정의
                let deleteAlert = Alert(style: .alert)
                    .setTitle("정말 삭제할까요?")
                    .setMessage("삭제하면 다시 복구할 수 없어요!")
                    .setAction(title: "닫기", style: .cancel)
                    .setAction(title: "삭제", style: .destructive) { _ in
                        // 삭제할 카드집
                        let deletedCard = self.cardZipList[indexPath.item]
                        
                        // 카드집 삭제
                        self.deleteCard(deletedCard)
                    }
                    .endSet()
                
                // 삭제 얼럿 띄우기
                present(deleteAlert, animated: true)
            }
            
            // 편집 얼럿 정의
            let editAlert = Alert(style: .actionSheet)
                .setAction(title: "닫기", style: .cancel)
                .setAction(title: "수정", style: .default)
                .setAction(title: "삭제", style: .destructive, handler: deleteHandler)
                .setAction(title: "MOCK 추가", style: .default, handler: { _ in
                    for mock in CardZip.mockData {
                        DBManager.shared.save(.card, documentName: mock.id, data: mock) { result in
                            print(result)
                        }
                    }
                })
                .endSet()
            
            // 편집 얼럿 띄우기
            present(editAlert, animated: true)
        } else {
            let selectedCardZip = cardZipList[indexPath.item]
            let rootVC = CardStudyViewController(cardZip: selectedCardZip)
            let cardStudyVC = UINavigationController(rootViewController: rootVC)
            
            cardStudyVC.modalPresentationStyle = .fullScreen
            
            present(cardStudyVC, animated: true)
        }
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
        
        if !cardZipList.isEmpty {
            cell.cardZip = cardZipList[indexPath.item]
        }
        
        cell.setupView()
        
        return cell
    }
}

// MARK: - UI 레이아웃
private extension MyCardListViewController {
    
    /// 내비게이션 바 설정
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "카드리스트"
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "편집",
            style: .plain,
            target: self,
            action: #selector(didTapModifyButton)
        )
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

struct Alert {
    typealias AlertAction = (title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?)
    
    let alertController: UIAlertController
    
    init(style: UIAlertController.Style) {
        self.alertController = UIAlertController(title: nil, message: nil, preferredStyle: style)
    }
    
    func setTitle(_ title: String) -> Self {
        alertController.title = title
        
        return self
    }
    
    func setMessage(_ message: String) -> Self {
        alertController.message = message
        
        return self
    }
    
    func setActions(_ actions: [AlertAction]) -> Self {
        actions.forEach {
            let action = UIAlertAction(title: $0.title, style: $0.style, handler: $0.handler)
            alertController.addAction(action)
        }
        
        return self
    }
    
    func setAction(title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        
        let action = UIAlertAction(title: title, style: style, handler: handler)
        
        alertController.addAction(action)
        
        return self
    }
    
    func endSet() -> UIAlertController {
        return alertController
    }
}
