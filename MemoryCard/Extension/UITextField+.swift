//
//  UITextField+.swift
//  MemoryCard
//
//  Created by yc on 2023/03/25.
//

import UIKit

extension UITextField {
    func offAutoChange(_ isOff: Bool) {
        autocapitalizationType = isOff ? .none : .sentences
        autocorrectionType = isOff ? .no : .default
    }
}
