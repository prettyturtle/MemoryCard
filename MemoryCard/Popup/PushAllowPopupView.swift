//
//  PushAllowPopupView.swift
//  MemoryCard
//
//  Created by yc on 2023/08/13.
//

import UIKit
import SnapKit
import Then

final class PushAllowPopupView: UIView, PopupView {
	
	weak var delegate: PopupViewDelegate?
	
	private lazy var dismissButton = UIButton().then {
		$0.tintColor = .orange
		let imageConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .light)
		let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
		$0.setImage(image, for: .normal)
		$0.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
	}
	private lazy var titleLabel = UILabel().then {
		$0.font = .Pretendard.b24
		$0.textColor = .label
		$0.text = "기기 알림이 꺼져있어요!"
		$0.textAlignment = .center
	}
	private lazy var subTitleLabel = UILabel().then {
		$0.font = .Pretendard.r14
		$0.textColor = .secondaryLabel
		$0.text = "공지사항 및 주요 업데이트 정보를\n알 수 있는 푸시 알림을 켜보세요"
		$0.textAlignment = .center
		$0.numberOfLines = 2
	}
	private lazy var bellImageView = UIImageView().then {
		$0.image = UIImage(named: "BellImage")
		$0.contentMode = .scaleAspectFit
	}
	private lazy var allowPushButton = OpacityButton().then {
		$0.style = .fill(backgroundColor: .systemOrange)
		$0.setTitle("알림 켜기", for: .normal)
		$0.addTarget(
			self,
			action: #selector(didTapAllowPushButton),
			for: .touchUpInside
		)
	}
	
	init() {
		super.init(frame: .zero)
		backgroundColor = .systemBackground
		
		setupLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func didTapDismissButton() {
		delegate?.popup(self, isDismiss: true)
	}
	@objc func didTapAllowPushButton() {
		delegate?.popup(self, action: .pushAllow)
	}
	
	private func setupLayout() {
		[
			dismissButton,
			titleLabel,
			subTitleLabel,
			bellImageView,
			allowPushButton
		].forEach {
			addSubview($0)
		}
		
		dismissButton.snp.makeConstraints {
			$0.size.equalTo(44.0)
			$0.top.trailing.equalToSuperview().inset(Constant.defaultInset / 2.0)
		}
		titleLabel.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(Constant.defaultInset)
			$0.top.equalTo(dismissButton.snp.bottom).offset(Constant.defaultInset / 2.0)
		}
		subTitleLabel.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(Constant.defaultInset / 2.0)
			$0.top.equalTo(titleLabel.snp.bottom).offset(Constant.defaultInset)
		}
		bellImageView.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(subTitleLabel.snp.bottom).offset(Constant.defaultInset)
			$0.width.equalToSuperview().dividedBy(2.0)
			$0.height.equalTo(bellImageView.snp.width)
		}
		allowPushButton.snp.makeConstraints {
			$0.leading.trailing.bottom.equalToSuperview().inset(Constant.defaultInset)
			$0.top.equalTo(bellImageView.snp.bottom).offset(Constant.defaultInset)
			$0.height.equalTo(48.0)
		}
	}
}
