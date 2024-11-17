//
//  MyInfoViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SnapKit
import Then
import FirebaseAuth

final class MyInfoViewController: BaseViewController {
    
    private lazy var test = OpacityButton().then {
        $0.style = .fill(backgroundColor: .systemGreen)
        $0.setTitle("회원확인", for: .normal)
        $0.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
    }
    private lazy var test2 = OpacityButton().then {
        $0.style = .fill(backgroundColor: .systemRed)
        $0.setTitle("로그아웃", for: .normal)
        $0.addTarget(
            self,
            action: #selector(didTapButton2),
            for: .touchUpInside
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
}

private extension MyInfoViewController {
    @objc func didTapButton(_ sender: UIButton) {
        let user = AuthManager.shared.getCurrentUser()
        
        let msg = """
            \(user?.email ?? "")
            \(user?.createdDate ?? .now)
            \(user?.lastSignInDate ?? .now)
        """
        
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func didTapButton2(_ sender: UIButton) {
        if AuthManager.shared.logout() {
            let rootVC = UINavigationController(rootViewController: LoginViewController())
            changeRootVC(rootVC, animated: true)
        }
    }
}

private extension MyInfoViewController {
    func setupLayout() {
        [
            test,
            test2
        ].forEach {
            view.addSubview($0)
        }
        
        test.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
        test2.snp.makeConstraints {
            $0.top.equalTo(test.snp.bottom).offset(Constant.defaultInset)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
    }
}
