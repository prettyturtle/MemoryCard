//
//  CreateCardIntroViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SnapKit
import Then

final class CreateCardIntroViewController: BaseViewController {
    
    private lazy var nextButton = OpacityButton().then {
        $0.setTitle("다음으로", for: .normal)
        $0.style = .fill(backgroundColor: .systemOrange)
        $0.addTarget(
            self,
            action: #selector(didTapNextButton),
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

private extension CreateCardIntroViewController {
    @objc func didTapNextButton(_ sender: UIButton) {
        let createCardFolderNameInputVC = CreateCardFolderNameInputViewController()
        navigationController?.pushViewController(createCardFolderNameInputVC, animated: true)
    }
    @objc func didTapDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

private extension CreateCardIntroViewController {
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(didTapDismissButton)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: nil
        )
    }
    func setupLayout() {
        [
            nextButton
        ].forEach {
            view.addSubview($0)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
    }
}
