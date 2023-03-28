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

final class HomeViewController: UIViewController {
    
    private lazy var createCardLabel = UILabel().then {
        $0.text = "동해물과백...\n두산이? 마르고닳 도록하느"
        $0.font = .systemFont(ofSize: 22.0, weight: .bold)
        $0.numberOfLines = 2
    }
    private lazy var createCardButton = OpacityButton().then {
        $0.setTitle("암기 카드 만들기", for: .normal)
        $0.style = .fill(backgroundColor: .systemOrange)
        $0.addTarget(
            self,
            action: #selector(didTapCreateCardButton),
            for: .touchUpInside
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupLayout()
    }
}

private extension HomeViewController {
    @objc func didTapCreateCardButton(_ sender: UIButton) {
        let createCardIntroVC = CreateCardIntroViewController()
        let createCardIntroNVC = UINavigationController(rootViewController: createCardIntroVC)
        
        createCardIntroNVC.modalPresentationStyle = .fullScreen
        present(createCardIntroNVC, animated: true)
    }
}

private extension HomeViewController {
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "star"),
            style: .plain,
            target: self,
            action: nil
        )
    }
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
