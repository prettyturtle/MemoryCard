//
//  BaseViewController.swift
//  MemoryCard
//
//  Created by yc on 11/17/24.
//

import UIKit
import Then

class BaseViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
	}
	
	func setNavBarLeftTitle(title: String) {
		let titleLabel = UILabel()
		titleLabel.text = title
		titleLabel.textColor = .label
		titleLabel.font = .Pretendard.b24
		
		let logoBarButton = UIBarButtonItem(customView: titleLabel)
		navigationItem.leftBarButtonItem = logoBarButton
		
		navigationController?.navigationBar.topItem?.backButtonTitle = ""
	}
	
	func setNavBarCenterTitle(title: String) {
		navigationController?.navigationBar.topItem?.backButtonTitle = ""
		
		let navBarTitleLabel = UILabel().then {
			$0.font = .Pretendard.m14
			$0.textColor = .label
			$0.text = title
		}
		
		navigationItem.titleView = navBarTitleLabel
	}
	
	func setNavBarXButton(action: Selector?) {
		let exitButton = UIBarButtonItem(
			image: .System.xmark,
			style: .plain,
			target: self,
			action: action
		)
		
		navigationItem.setLeftBarButton(exitButton, animated: true)
	}
}
