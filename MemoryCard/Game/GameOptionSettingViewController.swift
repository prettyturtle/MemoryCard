//
//  GameOptionSettingViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/10/30.
//

import UIKit
import SnapKit
import Then

final class GameOptionSettingViewController: UIViewController {
    
    private let gameMode: GameMode
    
    private lazy var optionListTableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.dataSource = self
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
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
    
    private func setupNavigationBar() {
        navigationItem.title = "게임 옵션"
    }
    
    private func setupLayout() {
        view.addSubview(optionListTableView)
        
        optionListTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension GameOptionSettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return gameMode.options.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameMode.options[section].selectionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CELL") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = "\(gameMode.options[indexPath.section]) - \(gameMode.options[indexPath.section].selectionList[indexPath.row].text)"
        
        return cell
    }
}
