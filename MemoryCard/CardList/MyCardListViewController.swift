//
//  MyCardListViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/04/11.
//

import UIKit
import SnapKit
import Then
import Toast
import GoogleMobileAds

// MARK: - 나의 카드 리스트 뷰컨
final class MyCardListViewController: BaseViewController {
	
	// MARK: ========================= < UI 컴포넌트 > =========================
	
	/// Google AdMob Banner View 1
	private lazy var bannerView = GADBannerView().then {
#if DEBUG
		$0.adUnitID = "ca-app-pub-3940256099942544/2934735716"
#else
		$0.adUnitID = "ca-app-pub-9209699720203850/2441509399" // Banner1
#endif
		$0.adSize = GADAdSizeBanner
		$0.rootViewController = self
		$0.load(GADRequest())
		$0.delegate = self
	}
	
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
	
	/// 카드가 없을 때 보여주는 이미지 뷰
	private lazy var emptyImageView = UIImageView().then {
		$0.image = UIImage(systemName: "tray")
		$0.tintColor = .placeholderText
		$0.contentMode = .scaleAspectFit
	}
	// MARK: ========================= </ UI 컴포넌트 > =========================
	
	
	// MARK: ========================= < 프로퍼티 > =========================
	
	private var cardZipList = [CardZip]()   // 카드 집 리스트
	private var isEdit = false              // 수정중 플래그
	
	// MARK: ========================= </ 프로퍼티 > ========================
}

// MARK: - 라이프 사이클
extension MyCardListViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		Task {
			if let storeVersion = await VersionChecker.getCurrentVersion(),
			   let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
				
				let isOld = VersionChecker.compareVersion(current: currentVersion, store: storeVersion)
				
				if isOld {
					print("업데이트 필요")
					
					let alert = Alert(style: .alert)
						.setTitle("업데이트 안내")
						.setMessage("🎉최신 버전이 나왔어요.🎉\n원활한 서비스 이용을 위해 앱을 업데이트해주세요.")
						.setAction(title: "이동", style: .default) { _ in
							if let url = URL(string: "itms-apps://itunes.apple.com/app/6450637636") {
								if UIApplication.shared.canOpenURL(url) {
									UIApplication.shared.open(url)
								}
							}
							
						}
						.endSet()
					
					present(alert, animated: true)
				}
			}
		}
		
		
		view.backgroundColor = .systemBackground // 배경색 설정
		
		setupNavigationBar()    // 내비게이션 설정
		setupLayout()           // 레이아웃 설정
		
		fetchCardZip()          // 카드 집 불러오기
		
		NotificationCenter
			.default
			.addObserver(
				self,
				selector: #selector(didFinishCreateCard),
				name: .DID_FINISH_CREATE_CARD,
				object: nil
			)
		
		NotificationCenter
			.default
			.addObserver(
				self,
				selector: #selector(didTapTutorialDimView),
				name: .TUTORIAL_DID_TAP_DIM_VIEW,
				object: nil
			)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		Task {
			let a = await VersionChecker.getCurrentVersion()
			
			
		}
		
		if let pushAllowTappedDate = UserDefaults.standard.value(forKey: IS_TAPPED_PUSH_ALLOW) as? Date {
			
			let intervalDate = Int(Date.now.timeIntervalSince(pushAllowTappedDate))
			
			if intervalDate >= 604800 {
				showPushAllowPopup()
			}
		} else {
			showPushAllowPopup()
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		// 화면을 이탈할 때 수정중이라면, 수정 모드 해제 -> 화면 갱신
		if isEdit {
			isEdit = false
			
			refreshView(isEdit: isEdit)
		}
	}
}

// MARK: - 로직
private extension MyCardListViewController {
	
	/// 푸시 알림 허용 팝업 노출
	func showPushAllowPopup() {
		UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { [weak self] settings in
			let allowStatus = settings.authorizationStatus
			
			if allowStatus != .authorized {
				DispatchQueue.main.async {
					let pop = PopupViewController(popupView: PushAllowPopupView())
					pop.modalPresentationStyle = .overFullScreen
					pop.modalTransitionStyle = .crossDissolve
					self?.present(pop, animated: true)
				}
			}
		})
	}
	
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
		
		let mIdx = currentUser.id                               // 유저 mIdx
		
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
			
			self.emptyImageView.isHidden = !self.cardZipList.isEmpty                        // 카드리스트 없을 때, 이미지 placeholder 보여줌
			self.homeMyCardListPreviewCollectionView.isHidden = self.cardZipList.isEmpty    // 카드리스트 없을 때, 콜렉션 뷰 숨기기
			
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
	
	/// 수정 모드인지 여부에 따라 화면 갱신
	func refreshView(isEdit: Bool) {
		if isEdit {
			navigationItem.rightBarButtonItem?.title = "완료"
			navigationController?.navigationBar.prefersLargeTitles = false
			setNavBarLeftTitle(title: "")
			setNavBarCenterTitle(title: "")
			homeMyCardListPreviewCollectionView.refreshControl = nil
		} else {
			navigationItem.rightBarButtonItem?.title = "편집"
			setNavBarLeftTitle(title: "카드리스트")
			homeMyCardListPreviewCollectionView.refreshControl = refreshControl
		}
		
		homeMyCardListPreviewCollectionView.reloadData()
	}
}

// MARK: - UI 이벤트
private extension MyCardListViewController {
	
	/// 튜토리얼 딤 뷰 탭 했을 때
	@objc func didTapTutorialDimView(_ notification: Notification) {
		guard let userInfo = notification.userInfo as? [String: Int],
			  let tutorialID = userInfo["id"] else {
			return
		}
		
		print(tutorialID, "🎉🎉")
		
		let nextID = tutorialID + 1
		
		if tutorialID == 1 {
			TutorialManager.shared.show(
				at: tabBarController ?? UITabBarController(),
				id: nextID,
				for: navigationController?.navigationBar ?? UINavigationBar(),
				text: "여기는 \"카드리스트\"에요",
				arrowPosition: .top
			)
		} else if tutorialID == 2 {
			TutorialManager.shared.show(
				at: tabBarController ?? UITabBarController(),
				id: nextID,
				for: navigationController?.navigationBar ?? UINavigationBar(),
				text: "만든 카드들을 볼 수 있는 곳이에요",
				arrowPosition: .top
			)
		} else if tutorialID == 3 {
			
			if cardZipList.isEmpty {
				cardZipList = CardZip.tutorialCardZip
				
				emptyImageView.isHidden = !cardZipList.isEmpty                        // 카드리스트 없을 때, 이미지 placeholder 보여줌
				homeMyCardListPreviewCollectionView.isHidden = cardZipList.isEmpty    // 카드리스트 없을 때, 콜렉션 뷰 숨기기
				
				homeMyCardListPreviewCollectionView.reloadData()
			}
			
			view.layoutIfNeeded()
			
			TutorialManager.shared.show(
				at: tabBarController ?? UITabBarController(),
				id: nextID,
				for: homeMyCardListPreviewCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) ?? navigationController?.navigationBar ?? UINavigationBar(),
				text: "카드를 선택하면 암기를 시작할 수 있어요!",
				arrowPosition: .top
			)
		} else if tutorialID == 5 {
			TutorialManager.shared.show(
				at: tabBarController ?? UITabBarController(),
				id: nextID,
				for: navigationItem.rightBarButtonItem ?? UIBarButtonItem(),
				text: "\"편집\"을 누르면 카드를 수정하거나 삭제할 수 있어요",
				arrowPosition: .top
			)
		} else if tutorialID == 6 {
			didTapModifyButton(navigationItem.rightBarButtonItem ?? UIBarButtonItem())
			
			TutorialManager.shared.show(
				at: tabBarController ?? UITabBarController(),
				id: nextID,
				for: navigationItem.rightBarButtonItem ?? UIBarButtonItem(),
				text: "편집이 끝나면 \"완료\"를 눌러주세요",
				arrowPosition: .top
			)
		} else if tutorialID == 7 {
			didTapModifyButton(navigationItem.rightBarButtonItem ?? UIBarButtonItem())
			
			if cardZipList.first?.mIdx == "Tutorial_mIdx" {
				cardZipList = []
				
				emptyImageView.isHidden = !cardZipList.isEmpty                        // 카드리스트 없을 때, 이미지 placeholder 보여줌
				homeMyCardListPreviewCollectionView.isHidden = cardZipList.isEmpty    // 카드리스트 없을 때, 콜렉션 뷰 숨기기
				
				homeMyCardListPreviewCollectionView.reloadData()
			}
			
			UserDefaults.standard.setValue(true, forKey: IS_DONE_TUTORIAL_INTRO)
		}
	}
	
	/// 카드 생성 완료
	@objc func didFinishCreateCard(_ notification: Notification) {
		guard let state = notification.userInfo?["isEdit"] as? Bool else {
			return
		}
		
		view.makeToast("카드 \(!state ? "생성" : "수정") 완료!")
		cardZipList = []
		fetchCardZip()
	}
	
	
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
		if cardZipList.isEmpty {
			view.makeToast("생성된 카드가 없어요!")
			return
		}
		
		isEdit.toggle()
		refreshView(isEdit: isEdit)
	}
}

// MARK: - CardListCollectionViewCellDelegate
extension MyCardListViewController: CardListCollectionViewCellDelegate {
	func didTapEditButton(_ cardZip: CardZip) {
		
		let rootVC = CreateCardFolderNameInputViewController()                                  // 카드 생성 VC (이름 입력 VC)
		let createCardFolderNameInputVC = UINavigationController(rootViewController: rootVC)    // 내비게이션 감싸기
		
		rootVC.willEditCardZip = cardZip                                                        // 수정모드
		createCardFolderNameInputVC.modalPresentationStyle = .fullScreen
		
		present(createCardFolderNameInputVC, animated: true)
		
	}
	
	func didTapDeleteButton(_ cardZip: CardZip) {
		// 삭제 얼럿 정의
		let deleteAlert = Alert(style: .alert)
			.setTitle("정말 삭제할까요?")
			.setMessage("삭제하면 다시 복구할 수 없어요!")
			.setAction(title: "닫기", style: .cancel)
			.setAction(title: "삭제", style: .destructive) { [weak self] _ in
				guard let self = self else {
					return
				}
				
				self.deleteCard(cardZip) // 카드집 삭제
			}
			.endSet()
		
		// 삭제 얼럿 띄우기
		present(deleteAlert, animated: true)
	}
	
	func didTapGameModeButton(_ cardZip: CardZip) {
		let gameModeSelectAlert = Alert(style: .actionSheet)
			.setTitle("게임 모드")
			.setMessage("모드를 선택해주세요.")
			.setAction(title: GameMode.quiz.title, style: .default) { [weak self] _ in
				guard let self = self else {
					return
				}
				
				let gameIntroVC = GameIntroViewController(gameMode: .quiz, cardZip: cardZip)
				let gameIntroNC = UINavigationController(rootViewController: gameIntroVC)
				
				gameIntroNC.modalPresentationStyle = .overFullScreen
				
				self.present(gameIntroNC, animated: true)
			}
			.setAction(title: GameMode.keyboard.title + "(오픈 준비중)", style: .default) { [weak self] _ in
				
				guard let self = self else {
					return
				}
				
				let openReadyAlert = Alert(style: .alert)
					.setTitle("오픈 준비중입니다.")
					.setMessage("조금만 기다려주세요! 🙇‍♀️")
					.setAction(title: "확인", style: .default)
					.endSet()
				
				self.present(openReadyAlert, animated: true)
			}
			.setAction(title: "취소", style: .cancel)
			.endSet()
		
		present(gameModeSelectAlert, animated: true)
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
		
		if !isEdit { // 편집 모드가 아닐 때 (일반 탭 -> 학습모드 이동)
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
		
		cell.delegate = self
		cell.setupLayout(isEdit: isEdit)
		
		if !cardZipList.isEmpty {
			cell.cardZip = cardZipList[indexPath.item]
		}
		
		cell.setupView()
		
		return cell
	}
}

// MARK: - GADBannerViewDelegate
extension MyCardListViewController: GADBannerViewDelegate {
	func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
		print("👛 bannerViewDidReceiveAd")
	}
	
	func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
		print("👛 bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
	}
	
	func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
		print("👛 bannerViewDidRecordImpression")
	}
	
	func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
		print("👛 bannerViewWillPresentScreen")
	}
	
	func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
		print("👛 bannerViewWillDIsmissScreen")
	}
	
	func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
		print("👛 bannerViewDidDismissScreen")
	}
}

// MARK: - UI 레이아웃
private extension MyCardListViewController {
	
	/// 내비게이션 바 설정
	func setupNavigationBar() {
		setNavBarLeftTitle(title: "카드리스트")
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
			emptyImageView,
			homeMyCardListPreviewCollectionView,
			bannerView
		].forEach {
			view.addSubview($0)
		}
		
		emptyImageView.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.size.equalTo(UIScreen.main.bounds.width / 2.0)
		}
		bannerView.snp.makeConstraints {
			$0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
		}
		
		homeMyCardListPreviewCollectionView.snp.makeConstraints {
			$0.top.equalTo(bannerView.snp.bottom)
			$0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
		}
	}
}
