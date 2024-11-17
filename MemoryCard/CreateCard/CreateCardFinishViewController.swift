//
//  CreateCardFinishViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/04/02.
//

import UIKit
import SnapKit
import Then
import Lottie
import GoogleMobileAds

// MARK: - 카드 생성 완료 뷰컨
final class CreateCardFinishViewController: UIViewController {
	// MARK: ========================= < UI 컴포넌트 > =========================
	
	/// 로티 애니메이션 뷰
	private lazy var lottieAnimationView = LottieAnimationView(name: "complete_lottie").then {
		$0.loopMode = .repeat(3)
	}
	
	/// 카드 생성 완료 라벨
	private lazy var finishLabel = UILabel().then {
		$0.text = !isEdit ? "카드 생성 완료!" : "카드 수정 완료!"
		$0.font = .Pretendard.b24
		$0.textAlignment = .center
	}
	
	/// 완료 버튼
	private lazy var finishButton = OpacityButton().then {
		$0.setTitle("완료", for: .normal)
		$0.style = .fill(backgroundColor: .systemOrange)
		$0.addTarget(
			self,
			action: #selector(didTapFinishButton),
			for: .touchUpInside
		)
	}
	
	private var interstitial: GADInterstitialAd?
	// MARK: ========================= </ UI 컴포넌트 > ========================
	
	// MARK: ========================= < 프로퍼티 > =========================
	private let folderName: String  // 카드 폴더 명
	private let cardList: [Card]    // 카드 리스트
	private let isEdit: Bool        // 최초 생성: false, 수정: true
	// MARK: ========================= </ 프로퍼티 > ========================
	
	// MARK: ========================= < init > =========================
	init(folderName: String, cardList: [Card], isEdit: Bool) {
		self.folderName = folderName
		self.cardList = cardList
		self.isEdit = isEdit
		super.init(nibName: nil, bundle: nil)
	}
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	// MARK: ========================= </ init > ========================
}

// MARK: - 라이프 사이클
extension CreateCardFinishViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		setupNavigationBar()
		setupLayout()
		
		lottieAnimationView.play()
		
		var adUnitID: String
		
		#if DEBUG
		adUnitID = "ca-app-pub-3940256099942544/4411468910"
		#else
		adUnitID = "ca-app-pub-9209699720203850/5501990840"
		#endif
		
		GADInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
			if let error = error {
				print("Failed to load interstitial ad with error: \(error.localizedDescription)")
				return
			}
			self?.interstitial = ad
			self?.interstitial?.fullScreenContentDelegate = self
		}
	}
}

// MARK: - UI 이벤트
private extension CreateCardFinishViewController {
	
	@objc func didTapDismissButton() {
		dismiss(animated: true)
		
		NotificationCenter
			.default
			.post(
				name: .DID_FINISH_CREATE_CARD,
				object: nil,
				userInfo: ["isEdit": isEdit]
			)
	}
	
	/// 완료 버튼을 눌렀을 때
	/// - Parameter sender: 완료 버튼
	@objc func didTapFinishButton(_ sender: UIButton) {
		guard let currentUser = AuthManager.shared.getCurrentUser() else {
			return
		}
		
		let mIdx = currentUser.id
		
		if mIdx == "LWtgt6ntq3d13PDWp45ZWcISQ2u1" {
			dismiss(animated: true)
			
			NotificationCenter
				.default
				.post(
					name: .DID_FINISH_CREATE_CARD,
					object: nil,
					userInfo: ["isEdit": isEdit]
				)
			
			return
		}
		
		if let interstitial = interstitial {
			interstitial.present(fromRootViewController: self)
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
			guard let self = self else {
				return
			}
			
			self.navigationItem.leftBarButtonItem = UIBarButtonItem(
				image: UIImage(systemName: "xmark"),
				style: .plain,
				target: self,
				action: #selector(self.didTapDismissButton)
			)
		}
	}
}

extension CreateCardFinishViewController: GADFullScreenContentDelegate {
	func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
		print("Ad did fail to present full screen content.")
		dismiss(animated: true)
		
		NotificationCenter
			.default
			.post(
				name: .DID_FINISH_CREATE_CARD,
				object: nil,
				userInfo: ["isEdit": isEdit]
			)
	}
	
	/// Tells the delegate that the ad will present full screen content.
	func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
		print("Ad will present full screen content.")
	}
	
	/// Tells the delegate that the ad dismissed full screen content.
	func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
		print("Ad did dismiss full screen content.")
		dismiss(animated: true)
		
		NotificationCenter
			.default
			.post(
				name: .DID_FINISH_CREATE_CARD,
				object: nil,
				userInfo: ["isEdit": isEdit]
			)
	}
}

private extension CreateCardFinishViewController {
	/// 내비게이션 설정
	func setupNavigationBar() {
		navigationItem.hidesBackButton = true
	}
	
	/// 레이아웃 설정
	func setupLayout() {
		[
			lottieAnimationView,
			finishLabel,
			finishButton
		].forEach {
			view.addSubview($0)
		}
		
		lottieAnimationView.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().multipliedBy(0.6)
			$0.size.equalTo(view.frame.width / 1.5)
		}
		finishLabel.snp.makeConstraints {
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
			$0.top.equalTo(lottieAnimationView.snp.bottom).offset(Constant.defaultInset)
		}
		finishButton.snp.makeConstraints {
			$0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
			$0.height.equalTo(48.0)
		}
	}
}
