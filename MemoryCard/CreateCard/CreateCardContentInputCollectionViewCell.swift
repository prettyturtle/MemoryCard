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
    
    // MARK: ========================= < UI 컴포넌트 > =========================
    /// 카드 앞면 뷰
    private lazy var frontCardView = UIView().then {
        $0.layer.cornerRadius = 12.0
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.layer.borderWidth = 0.4
    }
    
    /// 카드 뒷면 뷰
    private lazy var backCardView = UIView().then {
        $0.layer.cornerRadius = 12.0
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.layer.borderWidth = 0.4
    }
    
    /// 카드 앞면 텍스트뷰
    private lazy var frontContentInputTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 22.0, weight: .medium)
        $0.delegate = self
        $0.offAutoChange(true)
    }
    
    /// 카드 뒷면 텍스트뷰
    private lazy var backContentInputTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 22.0, weight: .medium)
        $0.delegate = self
        $0.offAutoChange(true)
    }
    
    /// 카드 앞면 텍스트뷰 플레이스홀더
    private lazy var frontContentPlaceholder = UILabel().then {
        $0.text = "앞"
        $0.textColor = .placeholderText
        $0.font = .systemFont(ofSize: 32.0, weight: .black)
    }
    
    /// 카드 뒷면 텍스트뷰 플레이스홀더
    private lazy var backContentPlaceholder = UILabel().then {
        $0.text = "뒤"
        $0.textColor = .placeholderText
        $0.font = .systemFont(ofSize: 32.0, weight: .black)
    }
    
    // MARK: ========================= </ UI 컴포넌트 > =========================
    
    // MARK: ========================= < 프로퍼티 > =========================
    var index: Int?                                                         // 현재 셀 인덱스
    var card: Card?                                                         // 현재 카드
    weak var delegate: CreateCardContentInputCollectionViewCellDelegate?    // 델리게이트
    // MARK: ========================= </ 프로퍼티 > =========================
}

// MARK: - 로직
extension CreateCardContentInputCollectionViewCell {
    
    /// 텍스트뷰 새로고침
    ///
    /// 콜랙션뷰의 재사용으로 인한 텍스트뷰의 텍스트 겹침 이슈 해결
    func reloadTextView() {
        frontContentInputTextView.text = card?.front.content    // 앞면 텍스트뷰 초기화
        backContentInputTextView.text = card?.back.content      // 앞면 텍스트뷰 초기화
    }
}

// MARK: - UITextViewDelegate
extension CreateCardContentInputCollectionViewCell: UITextViewDelegate {
    // 텍스트가 변경될 때마다 호출되는 함수
    func textViewDidChange(_ textView: UITextView) {
        guard let index = index else { // 현재 셀에 인덱스 값이 들어왔는지 확인
            return
        }
        
        guard let text = textView.text else { // 텍스트뷰 텍스트 옵셔널 해제
            return
        }
        
        var type: CardContentType
        
        switch textView {                                   // 텍스트가 변경된 텍스트뷰가
        case frontContentInputTextView:                     // 앞면 텍스트뷰일 때
            type = .front                                   // 타입 할당
            frontContentPlaceholder.isHidden = text != ""   // 플레이스홀더 노출/제거
        case backContentInputTextView:                      // 뒷면 텍스트뷰일 때
            type = .back                                    // 타입 할당
            backContentPlaceholder.isHidden = text != ""    // 플레이스홀더 노출/제거
        default:
            return
        }
        
        delegate?.createCardContentInputCollectionViewCell(
            didChangeContentText: self,
            index: index,
            text: text,
            type: type
        )                               // 델리게이트 함수 호출
    }
}

// MARK: - 뷰컨 재정의 함수
extension CreateCardContentInputCollectionViewCell {
    /// 화면을 터치했을 때
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.endEditing(true) // 키보드 내리기
    }
}

// MARK: - UI 레이아웃
extension CreateCardContentInputCollectionViewCell {
    /// 레이아웃 설정
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
        frontCardView.addSubview(frontContentPlaceholder)
        backCardView.addSubview(backContentInputTextView)
        backCardView.addSubview(backContentPlaceholder)
        
        frontContentInputTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constant.defaultInset / 2.0)
        }
        frontContentPlaceholder.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        backContentInputTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constant.defaultInset / 2.0)
        }
        backContentPlaceholder.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
