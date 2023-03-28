//
//  CreateCardContentInputViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/03/26.
//

import UIKit
import SnapKit
import Then

final class CreateCardContentInputViewController: UIViewController {
    
    private let folderName: String
    
    init(folderName: String) {
        self.folderName = folderName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var contentInputCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
    }
    private lazy var contentInputCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: contentInputCollectionViewLayout
    ).then {
        
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.dataSource = self
        $0.delegate = self
        $0.register(
            CreateCardContentInputCollectionViewCell.self,
            forCellWithReuseIdentifier: CreateCardContentInputCollectionViewCell.identifier
        )
    }
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

extension CreateCardContentInputViewController {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension CreateCardContentInputViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cellWidth = contentInputCollectionView.frame.width
        
        let currentIndex = Int(scrollView.contentOffset.x.truncatingRemainder(dividingBy: cellWidth) + 1)
        print(currentIndex)
    }
}

extension CreateCardContentInputViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CreateCardContentInputCollectionViewCell.identifier,
            for: indexPath
        ) as? CreateCardContentInputCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setupLayout()
        
        return cell
    }
}

private extension CreateCardContentInputViewController {
    @objc func didTapNextButton(_ sender: UIButton) {
        
    }
    @objc func didTapDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

private extension CreateCardContentInputViewController {
    func setupNavigationBar() {
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationItem.title = "카드 만들기"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: nil
        )
    }
    func setupLayout() {
        [
            contentInputCollectionView,
            nextButton
        ].forEach {
            view.addSubview($0)
        }
        
        contentInputCollectionView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
        }
        nextButton.snp.makeConstraints {
            $0.top.equalTo(contentInputCollectionView.snp.bottom).offset(Constant.defaultInset)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.defaultInset)
            $0.height.equalTo(48.0)
        }
    }
}
