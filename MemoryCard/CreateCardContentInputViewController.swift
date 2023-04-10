//
//  CreateCardContentInputViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SnapKit
import Then

// MARK: - 카드 내용 작성 뷰컨
final class CreateCardContentInputViewController: UIViewController {
    
    // MARK: ========================= < UI 컴포넌트 > =========================
    /// 도움말 버튼
    private lazy var infoRightBarButton = UIBarButtonItem(
        image: UIImage(systemName: "info.circle"),
        style: .plain,
        target: self,
        action: nil
    )
    
    /// 새 카드 생성 버튼
    private lazy var cardAddBarButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"),
        style: .plain,
        target: self,
        action: #selector(didTapCardAddBarButton)
    )
    
    /// 카드 콜렉션뷰 레이아웃
    private lazy var contentInputCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal // 스크롤 방향 좌우
    }
    
    /// 카드 콜렉션뷰
    private lazy var contentInputCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: contentInputCollectionViewLayout
    ).then {
        $0.showsHorizontalScrollIndicator = false   // 좌우 스크롤 가리기
        $0.isPagingEnabled = true                   // 스크롤할 때 딱딱
        $0.register(                                // 셀 등록
            CreateCardContentInputCollectionViewCell.self,
            forCellWithReuseIdentifier: CreateCardContentInputCollectionViewCell.identifier
        )
        $0.dataSource = self
        $0.delegate = self
    }
    
    /// 다음으로 이동 버튼
    private lazy var nextButton = OpacityButton().then {
        $0.setTitle("다음으로", for: .normal)                 // 버튼 타이틀 설정
        $0.style = .fill(backgroundColor: .systemOrange)    // 버튼 스타일 설정
        $0.addTarget(                                       // 버튼 이벤트 등록
            self,
            action: #selector(didTapNextButton),
            for: .touchUpInside
        )
    }
    // MARK: ========================= </ UI 컴포넌트 > =========================
    
    
    // MARK: ========================= < 프로퍼티 > =========================
    
    private let folderName: String      // 카드 폴더명
    private var cardList = [Card]()     // 생성된 카드 리스트
    private var currentCardIdx = 0 {    // 현재 카드 인덱스
        didSet {
            navigationItem.title = "카드 만들기 (\(currentCardIdx + 1)/\(cardList.count))" // 현재 카드 위치 나타내기
        }
    }
    
    // MARK: ========================= </ 프로퍼티 > =========================
    
    
    // MARK: ========================= < init > =========================
    init(folderName: String) {
        self.folderName = folderName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: ========================= </ init > =========================
}

// MARK: - 라이프 사이클
extension CreateCardContentInputViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground    // 배경색 설정
        setupNavigationBar()                        // 내비게이션 바 설정
        setupLayout()                               // 레이아웃 설정
        
        cardList = [Card.createDefault(id: 0)]      // 첫 카드 생성
        currentCardIdx = 0                          // 현재 카드 인덱스
    }
}

// MARK: - 로직
private extension CreateCardContentInputViewController {
    /// 새로운 카드 생성하는 함수
    func createNewCard() {
        let newLastIdx = cardList.count                     // 추가될 인덱스 (마지막 인덱스가 될 예정인 인덱스)
        let newCard = Card.createDefault(id: newLastIdx)    // 새 카드 생성
        
        cardList.append(newCard)                            // 새 카드 배열에 추가
        
        contentInputCollectionView.reloadData()             // 콜렉션 뷰 새로고침
        contentInputCollectionView.scrollToItem(
            at: IndexPath(item: newLastIdx, section: 0),
            at: .right,
            animated: true
        )                                                   // 마지막 셀로 이동
        
        currentCardIdx = newLastIdx                         // 현재 카드 인덱스 업데이트
    }
}

// MARK: - UI 이벤트
private extension CreateCardContentInputViewController {
    /// 새 카드 생성 버튼을 눌렀을 때
    /// - Parameter sender: 새 카드 생성 버튼
    @objc func didTapCardAddBarButton(_ sender: UIBarButtonItem) {
        createNewCard() // 새 카드 생성
    }
    
    /// 다음으로 이동 버튼을 눌렀을 때
    /// - Parameter sender: 다음으로 이동 버튼
    @objc func didTapNextButton(_ sender: UIButton) {
        IndicatorManager.shared.start()                                         // 카드 저장 시작, 인디케이터 시작
        
        let filteredCardList = cardList.filter {                                // 앞, 뒤 중 하나라도 채워져 있는 카드 리스트
            $0.front.content != "" || $0.back.content != ""                     // 카드 중 앞, 뒤 둘 다 비어있는 카드는 제거
        }
        
        guard let currentUser = AuthManager.shared.getCurrentUser() else {
            IndicatorManager.shared.stop()                                      // 인디케이터 중지
            return // TODO: - 현재 유저 없을 때 처리
        }
        
        let mIdx = currentUser.uid                                              // 유저 아이디
        
        let cardZip = CardZip(folderName: folderName, cards: filteredCardList, mIdx: mIdx)  // 카드 집 생성
        
        // DB 저장 시작
        DBManager.shared.save(.card, documentName: folderName, data: cardZip) { result in
            // DB 저장 완료
            IndicatorManager.shared.stop()                                      // 인디케이터 중지
            
            // TODO: - DB 저장 결과 처리
            print("DB 저장 결과 \(result)")
            
            let createCardFinishVC = CreateCardFinishViewController(            // 카드 생성 완료 뷰컨
                folderName: self.folderName,
                cardList: filteredCardList
            )
            self.navigationController?.pushViewController(                      // 카드 생성 완료 뷰컨으로 이동
                createCardFinishVC,
                animated: true
            )
        }
    }
}

// MARK: - 뷰컨 재정의 함수
extension CreateCardContentInputViewController {
    /// 화면 터치했을 때
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // 키보드 내리기
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CreateCardContentInputViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.width              // 셀 너비
        let height = collectionView.frame.height            // 셀 높이
        let cellSize = CGSize(width: width, height: height) // 셀 사이즈
        
        return cellSize                                     // 셀 사이즈 설정
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let edgeInset = 8.0 // 섹션의 테두리 마진
        return UIEdgeInsets(top: edgeInset, left: 0.0, bottom: edgeInset, right: 0.0) // 상하단에 마진 적용
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0.0
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0.0
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect() // 현재 스크롤 위치를 나타내는 네모
        
        visibleRect.origin = contentInputCollectionView.contentOffset           // 네모의 좌측 상단(origin) 위치 잡기, collectionView의 contentView의 위치
        visibleRect.size = contentInputCollectionView.bounds.size               // 네모의 사이즈 잡기, collectionView의 사이즈
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)    // 네모의 중심 구하기
        
        guard let indexPath = contentInputCollectionView.indexPathForItem(at: visiblePoint) else { // 네모의 중심이 포함된 셀의 인덱스
            return
        }
        
        currentCardIdx = indexPath.item // 현재 인덱스에 할당
    }
}

// MARK: - UICollectionViewDataSource
extension CreateCardContentInputViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CreateCardContentInputCollectionViewCell.identifier,
            for: indexPath
        ) as? CreateCardContentInputCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        cell.index = indexPath.item
        cell.card = cardList[indexPath.item]
        cell.reloadTextView()
        cell.setupLayout()
        
        return cell
    }
}

// MARK: - CreateCardContentInputCollectionViewCellDelegate
extension CreateCardContentInputViewController: CreateCardContentInputCollectionViewCellDelegate {
    func createCardContentInputCollectionViewCell(
        didChangeContentText cell: CreateCardContentInputCollectionViewCell,
        index: Int,
        text: String,
        type: CardContentType
    ) {
        guard let changedCardIdx = cardList.firstIndex(where: { $0.id == index }) else {
            return
        }
        
        switch type {
        case .front:
            cardList[changedCardIdx].front.content = text
        case .back:
            cardList[changedCardIdx].back.content = text
        }
    }
}

// MARK: - UI 레이아웃
private extension CreateCardContentInputViewController {
    func setupNavigationBar() {
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationItem.title = "카드 만들기"
        navigationItem.rightBarButtonItems = [cardAddBarButton, infoRightBarButton]
    }
    func setupLayout() {
        [
            contentInputCollectionView,
            nextButton
        ].forEach {
            view.addSubview($0)
        }
        
        contentInputCollectionView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
        }
        nextButton.snp.makeConstraints {
            $0.top.equalTo(contentInputCollectionView.snp.bottom).offset(Constant.defaultInset)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
    }
}
