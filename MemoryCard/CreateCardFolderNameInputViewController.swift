//
//  CreateCardFolderNameInputViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SnapKit
import Then

final class CreateCardFolderNameInputViewController: UIViewController {
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "폴더 이름 정하기"
        $0.font = .systemFont(ofSize: 24.0, weight: .bold)
    }
    private lazy var descriptionLabel = UILabel().then {
        $0.text = "폴더 이름은 나중에 변경할 수 있어요"
        $0.font = .systemFont(ofSize: 18.0, weight: .medium)
        $0.textColor = .secondaryLabel
    }
    private lazy var folderNameTextField = UITextField().then {
        $0.placeholder = "폴더 이름을 입력하세요..."
        $0.offAutoChange(true)
        $0.font = .systemFont(ofSize: 24.0, weight: .semibold)
        $0.delegate = self
    }
    private lazy var nextButton = OpacityButton().then {
        $0.setTitle("다음으로", for: .normal)
        $0.style = .border(borderColor: .systemOrange)
        $0.isEnabled = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        folderNameTextField.becomeFirstResponder()
    }
}

extension CreateCardFolderNameInputViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let folderName = folderNameTextField.text else { return }
        
        if folderName != "" {
            nextButton.isEnabled = true
            nextButton.style = .fill(backgroundColor: .systemOrange)
        } else {
            nextButton.isEnabled = false
            nextButton.style = .border(borderColor: .systemOrange)
        }
    }
}

extension CreateCardFolderNameInputViewController {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

private extension CreateCardFolderNameInputViewController {
    @objc func didTapNextButton(_ sender: UIButton) {
        guard let folderName = folderNameTextField.text else { return }
        let createCardContentInputViewController = CreateCardContentInputViewController(folderName: folderName)
        navigationController?.pushViewController(createCardContentInputViewController, animated: true)
    }
    @objc func didTapDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

private extension CreateCardFolderNameInputViewController {
    func setupNavigationBar() {
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: nil
        )
    }
    func setupLayout() {
        [
            titleLabel,
            descriptionLabel,
            folderNameTextField,
            nextButton
        ].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
        }
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constant.defaultInset)
        }
        folderNameTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(Constant.defaultInset * 2)
            $0.height.equalTo(48.0)
        }
        nextButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
    }
}
