//
//  CardStudyViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/04/15.
//

import UIKit
import SnapKit
import Then

// MARK: - 카드 공부 뷰컨
final class CardStudyViewController: UIViewController {
    
}

// MARK: - 라이프 사이클
extension CardStudyViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground    // 배경색 설정
        setupNavigationBar()                        // 내비게이션 설정
        setupLayout()                               // 레이아웃 설정
    }
}

// MARK: - UI 이벤트
private extension CardStudyViewController {
    @objc func didTapDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - UI 레이아웃
private extension CardStudyViewController {
    
    /// 내비게이션 바 설정
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.addDismissButton(self, action: #selector(didTapDismissButton))
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    /// 레이아웃 설정
    func setupLayout() {
        
       
    }
}
