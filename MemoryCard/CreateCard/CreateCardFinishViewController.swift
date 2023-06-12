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

// MARK: - 카드 생성 완료 뷰컨
final class CreateCardFinishViewController: UIViewController {
    // MARK: ========================= < UI 컴포넌트 > =========================
    
    /// 로티 애니메이션 뷰
    private lazy var lottieAnimationView = LottieAnimationView(name: "complete_lottie").then {
        $0.loopMode = .repeat(3)
    }
    
    /// 카드 생성 완료 라벨
    private lazy var finishLabel = UILabel().then {
        $0.text = "카드 생성 완료!"
        $0.font = .systemFont(ofSize: 24.0, weight: .bold)
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
    // MARK: ========================= </ UI 컴포넌트 > ========================
    
    // MARK: ========================= < 프로퍼티 > =========================
    private let folderName: String  // 카드 폴더 명
    private let cardList: [Card]    // 카드 리스트
    // MARK: ========================= </ 프로퍼티 > ========================
    
    // MARK: ========================= < init > =========================
    init(folderName: String, cardList: [Card]) {
        self.folderName = folderName
        self.cardList = cardList
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
    }
}

// MARK: - UI 이벤트
private extension CreateCardFinishViewController {
    
    /// 완료 버튼을 눌렀을 때
    /// - Parameter sender: 완료 버튼
    @objc func didTapFinishButton(_ sender: UIButton) {
        dismiss(animated: true)
        
        NotificationCenter
            .default
            .post(
                name: .didFinishCreateCard,
                object: nil
            )
    }
}

extension NSNotification.Name {
    static let didFinishCreateCard = NSNotification.Name("DID_FINISH_CREATE_CARD")
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
