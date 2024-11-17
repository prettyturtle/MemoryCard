//
//  GameIntroViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/10/29.
//

import UIKit
import SnapKit
import Then

final class GameIntroViewController: BaseViewController {
	
	private let gameMode: GameMode
	private var gameModeOptions: [GameModeOption: Int]
	private let cardZip: CardZip
	
	private lazy var titleLabel = UILabel().then {
		$0.text = gameMode.title
		$0.font = .Pretendard.b32
		$0.textAlignment = .left
		$0.textColor = .label
	}
	
	private lazy var descriptionLabel = UILabel().then {
		$0.text = gameMode.description
		$0.font = .Pretendard.m16
		$0.textAlignment = .left
		$0.textColor = .secondaryLabel
		$0.numberOfLines = 0
	}
	
	private lazy var startButton = OpacityButton().then {
		$0.style = .fill(backgroundColor: .systemOrange)
		$0.setTitle("시작하기", for: .normal)
		$0.addTarget(
			self,
			action: #selector(didTapStartButton),
			for: .touchUpInside
		)
	}
	
	init(gameMode: GameMode, cardZip: CardZip) {
		self.gameMode = gameMode
		self.cardZip = cardZip
		
		var tempGameModeOptions = [GameModeOption: Int]()
		
		if let savedGameModeOptionsData = UserDefaults.standard.data(forKey: GAME_MODE_OPTIONS),
		   let savedGameModeOptions = try? JSONDecoder().decode([GameModeOption: Int].self, from: savedGameModeOptionsData) {
			tempGameModeOptions = savedGameModeOptions
		} else {
			for option in gameMode.options {
				tempGameModeOptions[option] = option.defaultValue
			}
		}
		
		self.gameModeOptions = tempGameModeOptions
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
	
	@objc func didTapOptionSettingButton(_ sender: UIBarButtonItem) {
		let gameOptionSettingVC = GameOptionSettingViewController(
			gameMode: gameMode,
			gameModeOptions: gameModeOptions
		)
		
		gameOptionSettingVC.delegate = self
		
		navigationController?.pushViewController(gameOptionSettingVC, animated: true)
	}
	
	@objc func didTapStartButton(_ sender: UIButton) {
		var gameVC: UIViewController
		
		switch gameMode {
		case .quiz:
			gameVC = GameQuizViewController(
				cardZip: cardZip,
				gameModeOptions: gameModeOptions
			)
		case .keyboard:
			gameVC = GameQuizViewController(
				cardZip: cardZip,
				gameModeOptions: gameModeOptions
			)
		}
		
		navigationController?.pushViewController(gameVC, animated: true)
	}
	
	private func setupNavigationBar() {
		navigationItem.addDismissButton(self, action: #selector(didTapDismissButton))
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "gearshape"),
			style: .plain,
			target: self,
			action: #selector(didTapOptionSettingButton)
		)
	}
	
	private func setupLayout() {
		[
			titleLabel,
			descriptionLabel,
			startButton
		].forEach {
			view.addSubview($0)
		}
		
		titleLabel.snp.makeConstraints {
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset * 2)
		}
		
		descriptionLabel.snp.makeConstraints {
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
			$0.top.equalTo(titleLabel.snp.bottom).offset(Constant.defaultInset)
		}
		
		startButton.snp.makeConstraints {
			$0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
			$0.height.equalTo(48.0)
		}
	}
}

extension GameIntroViewController: GameOptionSettingViewControllerDelegate {
	func didSelectGameOption(_ gameModeOptions: [GameModeOption : Int]) {
		self.gameModeOptions = gameModeOptions
		
		let gameModeOptionsData = try! JSONEncoder().encode(gameModeOptions)
		
		UserDefaults.standard.setValue(gameModeOptionsData, forKey: GAME_MODE_OPTIONS)
	}
}
