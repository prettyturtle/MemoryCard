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
    
    var willEditCardZip: CardZip? // nil이면 최소 생성, nil이 아니면 수정
}

extension CreateCardFolderNameInputViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupLayout()
        
        setupEditMode() // 수정 모드 세팅
        
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(didTapTutorialDimView),
                name: .TUTORIAL_DID_TAP_DIM_VIEW,
                object: nil
            )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isDoneTutorialCreateCardFolderNameInput = UserDefaults.standard.bool(forKey: "IS_DONE_TUTORIAL_CREATE_CARD_FOLDER_NAME_INPUT")
        
        if !isDoneTutorialCreateCardFolderNameInput {
            TutorialManager.shared.show(
                at: navigationController ?? self,
                id: 30,
                for: nextButton,
                text: "이제 카드를 만들어 볼까요? 🙆‍♀️",
                arrowPosition: .bottom
            )
        }
        
        folderNameTextField.becomeFirstResponder()
    }
}

extension CreateCardFolderNameInputViewController {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

private extension CreateCardFolderNameInputViewController {
    func setupEditMode() {
        if let willEditCardZip = willEditCardZip {
            folderNameTextField.text = willEditCardZip.folderName
        }
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

private extension CreateCardFolderNameInputViewController {
    
    /// 튜토리얼 딤 뷰 탭 했을 때
    @objc func didTapTutorialDimView(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Int],
              let tutorialID = userInfo["id"] else {
            return
        }
        
        print(tutorialID, "🎉🎉")
        
        let nextID = tutorialID + 1
        
        if tutorialID == 30 {
            TutorialManager.shared.show(
                at: navigationController ?? self,
                id: nextID,
                for: folderNameTextField,
                text: "제일 먼저 카드들을 대표하는 폴더 이름을 정해주세요",
                arrowPosition: .top
            )
        } else if tutorialID == 31 {
            TutorialManager.shared.show(
                at: navigationController ?? self,
                id: nextID,
                for: nextButton,
                text: "폴더 이름을 정했으면 다음으로 이동하세요!",
                arrowPosition: .bottom
            )
            
            UserDefaults.standard.setValue(true, forKey: "IS_DONE_TUTORIAL_CREATE_CARD_FOLDER_NAME_INPUT")
        }
    }
    
    @objc func didTapNextButton(_ sender: UIButton) {
        guard let folderName = folderNameTextField.text else { return }
        let createCardContentInputViewController = CreateCardContentInputViewController(folderName: folderName)
        createCardContentInputViewController.willEditCardZip = willEditCardZip // 수정모드
        navigationController?.pushViewController(createCardContentInputViewController, animated: true)
    }
    @objc func didTapDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

private extension CreateCardFolderNameInputViewController {
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(didTapDismissButton)
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
