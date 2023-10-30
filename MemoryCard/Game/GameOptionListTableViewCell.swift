//
//  GameOptionListTableViewCell.swift
//  MemoryCard
//
//  Created by yc on 2023/10/30.
//

import UIKit
import SnapKit
import Then

final class GameOptionListTableViewCell: UITableViewCell {
    static let identifier = "GameOptionListTableViewCell"
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .label
    }
    
    private lazy var checkImageView = UIImageView().then {
        $0.image = UIImage(systemName: "checkmark")
        $0.tintColor = .systemOrange
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    func setupView(title: String, isChecked: Bool) {
        setupLayout()
        
        titleLabel.text = title
        checkImageView.isHidden = !isChecked
    }
    
    private func setupLayout() {
        [
            titleLabel,
            checkImageView
        ].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Constant.defaultInset)
            $0.top.bottom.equalToSuperview().inset(Constant.defaultInset / 2)
        }
        
        checkImageView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(Constant.defaultInset / 2)
            $0.top.bottom.equalTo(titleLabel)
            $0.width.equalTo(checkImageView.snp.height)
            $0.trailing.equalToSuperview().inset(Constant.defaultInset)
        }
    }
}
