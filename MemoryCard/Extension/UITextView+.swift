//
//  UITextView+.swift
//  MemoryCard
//
//  Created by yc on 2023/04/02.
//

import Foundation
import UIKit

extension UITextView {
    func offAutoChange(_ isOff: Bool) {
        autocapitalizationType = isOff ? .none : .sentences
        autocorrectionType = isOff ? .no : .default
    }
}
