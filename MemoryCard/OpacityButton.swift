//
//  OpacityButton.swift
//  MemoryCard
//
//  Created by yc on 2023/03/25.
//

import UIKit

final class OpacityButton: UIButton {
    
    enum Style {
        case border(borderColor: UIColor)
        case fill(backgroundColor: UIColor)
    }
    
    var style: Style = .fill(backgroundColor: .black) {
        didSet {
            switch style {
            case .fill(let color):
                backgroundColor = color
                layer.borderWidth = 0.0
                setTitleColor(.white, for: .normal)
            case .border(let color):
                backgroundColor = .clear
                layer.borderColor = color.cgColor
                layer.borderWidth = 1.0
                setTitleColor(color, for: .normal)
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            didChangeHighlighted(isHighlighted)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureDefaultUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func didChangeHighlighted(_ isHighlighted: Bool) {
        alpha = isHighlighted ? 0.4 : 1.0
    }
    
    private func configureDefaultUI() {
        layer.cornerRadius = 12.0
        backgroundColor = .black
        setTitle("SET TITLE", for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16.0, weight: .semibold)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }
}
