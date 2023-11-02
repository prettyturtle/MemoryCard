//
//  GameOptionSettingViewController.swift
//  MemoryCard
//
//  Created by yc on 2023/10/30.
//

import UIKit
import SnapKit
import Then

protocol GameOptionSettingViewControllerDelegate: AnyObject {
    func didSelectGameOption(_ gameModeOptions: [GameModeOption: Int])
}

final class GameOptionSettingViewController: UIViewController {
    
    private let gameMode: GameMode
    private var gameModeOptions: [GameModeOption: Int]
    
    weak var delegate: GameOptionSettingViewControllerDelegate?
    
    private lazy var optionListTableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(
            GameOptionListTableViewCell.self,
            forCellReuseIdentifier: GameOptionListTableViewCell.identifier
        )
    }
    
    init(gameMode: GameMode, gameModeOptions: [GameModeOption: Int]) {
        self.gameMode = gameMode
        self.gameModeOptions = gameModeOptions
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return gameMode.options[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: GameOptionListTableViewCell.identifier
        ) as? GameOptionListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        
        let gameModeOption = gameMode.options[indexPath.section]
        let gameModeOptionSelectionItem = gameModeOption.selectionList[indexPath.row]
        let gameModeOptionTitle = gameModeOptionSelectionItem.text
        let isChecked = gameModeOptions[gameModeOption] == gameModeOptionSelectionItem.idx
        cell.setupView(title: gameModeOptionTitle, isChecked: isChecked)
        
        return cell
    }
}

extension GameOptionSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gameModeOption = gameMode.options[indexPath.section]
        let gameModeOptionSelectionItem = gameModeOption.selectionList[indexPath.row]
        
        gameModeOptions[gameModeOption] = gameModeOptionSelectionItem.idx
        delegate?.didSelectGameOption(gameModeOptions)
        tableView.reloadData()
    }
}
