//
//  HomeViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SnapKit
import Then
import FirebaseAuth

// MARK: - 홈 뷰컨
final class HomeViewController: UIViewController {
    
    // MARK: ========================= < UI 컴포넌트 > =========================
    /// 카드 생성 라벨
    private lazy var createCardLabel = UILabel().then {
        $0.text = "동해물과백...\n두산이? 마르고닳 도록하느"
        $0.font = .systemFont(ofSize: 22.0, weight: .bold)
        $0.numberOfLines = 2
    }
    
    /// 카드 생성 버튼
    private lazy var createCardButton = OpacityButton().then {
        $0.setTitle("암기 카드 만들기", for: .normal)
        $0.style = .fill(backgroundColor: .systemOrange)
        $0.addTarget(
            self,
            action: #selector(didTapCreateCardButton),
            for: .touchUpInside
        )
    }
    // MARK: ========================= </ UI 컴포넌트 > =========================
}

// MARK: - 라이프 사이클
extension HomeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // 배경색 설정
        
        setupNavigationBar()    // 내비게이션 설정
        setupLayout()           // 레이아웃 설정
    }
}

// MARK: - UI 이벤트
private extension HomeViewController {
    
    /// 카드 생성 버튼을 눌렀을 때
    /// - Parameter sender: 카드 생성 버튼
    @objc func didTapCreateCardButton(_ sender: UIButton) {
        let createCardIntroVC = CreateCardIntroViewController()                                 // 카드 생성 뷰컨
        let createCardIntroNVC = UINavigationController(rootViewController: createCardIntroVC)  // 카드 생성 NVC
        
        createCardIntroNVC.modalPresentationStyle = .fullScreen                                 // 풀스크린
        present(createCardIntroNVC, animated: true)                                             // 카드 뷰컨 띄우기
    }
}

// MARK: - UI 레이아웃
private extension HomeViewController {
    
    /// 내비게이션 바 설정
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "star"),
            style: .plain,
            target: self,
            action: nil
        )
    }
    
    /// 레이아웃 설정
    func setupLayout() {
        [
            createCardLabel,
            createCardButton
        ].forEach {
            view.addSubview($0)
        }
        
        createCardLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
        }
        createCardButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(createCardLabel.snp.bottom).offset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
    }
}
