//
//  CardStudyViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/04/15.
//

import UIKit
import SnapKit
import Then
import GoogleMobileAds

// MARK: - 카드 공부 뷰컨
final class CardStudyViewController: BaseViewController {
	
	enum CardScrollDirection {
		case next
		case prev
	}
	
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
	
	/// Google AdMob Banner View 2
	private lazy var bannerView = GADBannerView().then {
#if DEBUG
		$0.adUnitID = "ca-app-pub-3940256099942544/2934735716"
#else
		$0.adUnitID = "ca-app-pub-9209699720203850/6900517207" // Banner2
#endif
		$0.adSize = GADAdSizeBanner
		$0.rootViewController = self
		$0.load(GADRequest())
		$0.delegate = self
	}
	
	private lazy var autoProgressView = UIProgressView()
	
	private lazy var bottomTabView = UIView().then {
		$0.backgroundColor = .secondarySystemBackground
	}
	
	private lazy var pageControlView = UIView()
	
	private lazy var prevCardButton = UIButton().then {
		$0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25.0), forImageIn: .normal)
		$0.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
		$0.tintColor = .black
		$0.addTarget(
			self,
			action: #selector(didTapPrevNextCardButton),
			for: .touchUpInside
		)
	}
	
	private lazy var playAutoButton = UIButton().then {
		$0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 40.0), forImageIn: .normal)
		$0.setImage(UIImage(systemName: "play.fill"), for: .normal)
		$0.tintColor = .black
		$0.addTarget(
			self,
			action: #selector(didTapPlayAutoButton),
			for: .touchUpInside
		)
	}
	
	private lazy var nextCardButton = UIButton().then {
		$0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25.0), forImageIn: .normal)
		$0.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
		$0.tintColor = .black
		$0.addTarget(
			self,
			action: #selector(didTapPrevNextCardButton),
			for: .touchUpInside
		)
	}
	
	// MARK: ========================= </ UI 컴포넌트 > ========================
	
	
	// MARK: ========================= < 프로퍼티 > =========================
	
	private let cardZip: CardZip
	private var currentCardIdx = 0 {
		didSet {
			setEnablePrevNextButton()
		}
	}
	private var isAuto = false
	private var autoHandler: DispatchWorkItem?
	private var autoTimer: Timer?
	private var autoProgress: Float = 0.0
	private var currentAutoPlaySpeed = UserDefaults.standard.integer(forKey: AUTO_PLAY_SPEED) == 0 ? 3 : UserDefaults.standard.integer(forKey: AUTO_PLAY_SPEED)
	
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
		setEnablePrevNextButton()                   // prev, next 버튼 enable 세팅
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
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		var visibleRect = CGRect() // 현재 스크롤 위치를 나타내는 네모
		
		visibleRect.origin = cardStudyCollectionView.contentOffset           // 네모의 좌측 상단(origin) 위치 잡기, collectionView의 contentView의 위치
		visibleRect.size = cardStudyCollectionView.bounds.size               // 네모의 사이즈 잡기, collectionView의 사이즈
		
		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)    // 네모의 중심 구하기
		
		guard let indexPath = cardStudyCollectionView.indexPathForItem(at: visiblePoint) else { // 네모의 중심이 포함된 셀의 인덱스
			return
		}
		
		currentCardIdx = indexPath.item // 현재 인덱스에 할당
	}
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		stopAutoScroll()
		isAuto = false
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
		cell.setupLayout()
		cell.setupView()
		
		return cell
	}
}

// MARK: - 로직
private extension CardStudyViewController {
	func setEnablePrevNextButton() {
		prevCardButton.isEnabled = currentCardIdx != 0
		nextCardButton.isEnabled = currentCardIdx != cardZip.cards.count - 1
	}
	
	func scrollToCard(direction: CardScrollDirection) {
		switch direction {
		case .prev:
			if currentCardIdx > 0 {
				currentCardIdx -= 1
				
				let prevIndexPath = IndexPath(item: currentCardIdx, section: 0)
				
				cardStudyCollectionView.scrollToItem(at: prevIndexPath, at: .left, animated: true)
			}
		case .next:
			if currentCardIdx < cardZip.cards.count - 1 {
				currentCardIdx += 1
				
				let nextIndexPath = IndexPath(item: currentCardIdx, section: 0)
				
				cardStudyCollectionView.scrollToItem(at: nextIndexPath, at: .right, animated: true)
			}
		}
	}
	
	func startAutoScroll() {
		guard let autoHandler = autoHandler else {
			return
		}
		
		playAutoButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
		
		autoProgressView.progressTintColor = .systemOrange
		
		autoProgress = 0.0
		autoProgressView.setProgress(0.0, animated: false)
		
		autoTimer?.invalidate()
		
		autoTimer = Timer.scheduledTimer(
			timeInterval: 0.01,
			target: self,
			selector: #selector(beginTimer),
			userInfo: nil,
			repeats: true
		)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.currentAutoPlaySpeed), execute: autoHandler)
	}
	
	func stopAutoScroll() {
		playAutoButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		
		autoTimer?.invalidate()
		autoHandler?.cancel()
		autoTimer = nil
		
		autoProgress = 0.0
		autoProgressView.setProgress(0.0, animated: true)
	}
}

// MARK: - UI 이벤트
private extension CardStudyViewController {
	@objc func beginTimer() {
		autoProgress += 1.0
		autoProgressView.setProgress(autoProgress / (Float(currentAutoPlaySpeed) * 200.0), animated: true)
	}
	@objc func didTapPlayAutoButton(_ sender: UIButton) {
		isAuto.toggle()
		
		if isAuto {
			autoHandler = DispatchWorkItem(block: {
				if !self.isAuto { return }
				
				let currentIndexPath = IndexPath(item: self.currentCardIdx, section: 0)
				
				guard let cell = self.cardStudyCollectionView.cellForItem(at: currentIndexPath) as? CardStudyCollectionViewCell else {
					return
				}
				
				cell.rotateCard()
				self.autoProgressView.progressTintColor = .systemRed
				
				DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.currentAutoPlaySpeed)) {
					if !self.isAuto { return }
					
					if self.currentCardIdx == self.cardZip.cards.count - 1 {
						self.stopAutoScroll()
						self.isAuto = false
						return
					}
					
					self.scrollToCard(direction: .next)
					self.startAutoScroll()
				}
			})
			
			startAutoScroll()
		} else {
			stopAutoScroll()
		}
	}
	
	@objc func didTapPrevNextCardButton(_ sender: UIButton) {
		if isAuto {
			stopAutoScroll()
			isAuto = false
		}
		
		var direction: CardScrollDirection
		
		switch sender {
		case prevCardButton:
			direction = .prev
		case nextCardButton:
			direction = .next
		default:
			return
		}
		
		scrollToCard(direction: direction)
	}
	
	@objc func didTapOptionSettingButton(_ sender: UIBarButtonItem) {
		let optionSettingAlert = Alert(style: .actionSheet)
			.setTitle("옵션")
			.setAction(title: "닫기", style: .cancel)
			.setAction(title: "자동 재생 속도", style: .default) { [weak self] _ in
				let autoPlaySpeedAlert = Alert(style: .actionSheet)
					.setTitle("자동 재생 속도")
					.setAction(title: "닫기", style: .cancel)
					.setActions(
						[1, 3, 5, 7].map { speed -> Alert.AlertAction in
							let speedAction = Alert.AlertAction(
								title: self?.currentAutoPlaySpeed == speed ? "✓ \(speed)초" : "\(speed)초",
								style: .default
							) { _ in
								self?.currentAutoPlaySpeed = speed
								UserDefaults.standard.setValue(speed, forKey: AUTO_PLAY_SPEED)
							}
							
							return speedAction
						}
					)
					.endSet()
				
				self?.present(autoPlaySpeedAlert, animated: true)
			}
			.endSet()
		
		present(optionSettingAlert, animated: true)
	}
	
	@objc func didTapDismissButton(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
}

// MARK: - GADBannerViewDelegate
extension CardStudyViewController: GADBannerViewDelegate {
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
private extension CardStudyViewController {
	
	/// 내비게이션 바 설정
	func setupNavigationBar() {
		setNavBarCenterTitle(title: cardZip.folderName)
		setNavBarXButton(action: #selector(didTapDismissButton))
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "ellipsis"),
			style: .plain,
			target: self,
			action: #selector(didTapOptionSettingButton)
		)
	}
	
	/// 레이아웃 설정
	func setupLayout() {
		[
			cardStudyCollectionView,
			bottomTabView,
			pageControlView,
			bannerView
		].forEach {
			view.addSubview($0)
		}
		
		bannerView.snp.makeConstraints {
			$0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
		}
		
		cardStudyCollectionView.snp.makeConstraints {
			$0.top.equalTo(bannerView.snp.bottom).offset(Constant.defaultInset)
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
		}
		
		bottomTabView.snp.makeConstraints {
			$0.top.equalTo(cardStudyCollectionView.snp.bottom).offset(Constant.defaultInset)
			$0.leading.trailing.bottom.equalToSuperview()
			$0.height.equalTo(120.0)
		}
		
		pageControlView.snp.makeConstraints {
			$0.leading.top.trailing.equalTo(bottomTabView)
			$0.bottom.equalTo(view.safeAreaLayoutGuide)
		}
		
		[
			autoProgressView,
			prevCardButton,
			playAutoButton,
			nextCardButton
		].forEach {
			pageControlView.addSubview($0)
		}
		
		autoProgressView.snp.makeConstraints {
			$0.leading.top.trailing.equalToSuperview()
			$0.height.equalTo(2.0)
		}
		
		playAutoButton.snp.makeConstraints {
			$0.center.equalToSuperview()
			$0.top.bottom.equalToSuperview().inset(16.0)
			$0.width.equalTo(playAutoButton.snp.height)
		}
		
		prevCardButton.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.trailing.equalTo(playAutoButton.snp.leading).offset(-Constant.defaultInset * 2)
		}
		
		nextCardButton.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(playAutoButton.snp.trailing).offset(Constant.defaultInset * 2)
		}
	}
}
