//
//  GameIntroViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/10/29.
//

import UIKit
import SnapKit
import Then

final class GameIntroViewController: UIViewController {
    
    private let gameMode: GameMode
    
    private lazy var titleLabel = UILabel().then {
        $0.text = gameMode.title
        $0.font = .systemFont(ofSize: 32, weight: .bold)
        $0.textAlignment = .left
        $0.textColor = .label
    }
    
    private lazy var descriptionLabel = UILabel().then {
        $0.text = gameMode.description
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .left
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
    }
    
    
    init(gameMode: GameMode) {
        self.gameMode = gameMode
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
    
    private func setupNavigationBar() {
        navigationItem.addDismissButton(self, action: #selector(didTapDismissButton))
    }
    
    private func setupLayout() {
        [
            titleLabel,
            descriptionLabel
        ].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset * 2)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
    }
}
