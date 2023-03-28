//
//  CreateCardContentInputCollectionViewCell.swift
//  MemoryCard
//
//  Created by yc on 2023/03/28.
//

import UIKit
import SnapKit
import Then

final class CreateCardContentInputCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: CreateCardContentInputCollectionViewCell.self)
    
    private lazy var frontCardView = UIView().then {
        $0.layer.cornerRadius = 12.0
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.layer.borderWidth = 0.4
    }
    private lazy var backCardView = UIView().then {
        $0.layer.cornerRadius = 12.0
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.layer.borderWidth = 0.4
    }
    private lazy var frontContentInputTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 22.0, weight: .medium)
    }
    private lazy var backContentInputTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 22.0, weight: .medium)
    }
    
    func setupLayout() {
        [
            frontCardView,
            backCardView
        ].forEach {
            contentView.addSubview($0)
        }
        
        frontCardView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(Constant.defaultInset)
            $0.bottom.equalTo(contentView.snp.centerY).offset(-Constant.defaultInset / 2.0)
        }
        backCardView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.centerY).offset(Constant.defaultInset / 2.0)
            $0.leading.trailing.bottom.equalToSuperview().inset(Constant.defaultInset)
        }
        
        frontCardView.addSubview(frontContentInputTextView)
        backCardView.addSubview(backContentInputTextView)
        
        frontContentInputTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constant.defaultInset / 2.0)
        }
        backContentInputTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constant.defaultInset / 2.0)
        }
    }
}

extension CreateCardContentInputCollectionViewCell {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.endEditing(true)
    }
}
