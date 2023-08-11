//
//  Alert.swift
//  MemoryCard
//
//  Created by yc on 2023/05/16.
//

import UIKit

struct Alert {
    typealias AlertAction = (title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?)
    
    let alertController: UIAlertController
    
    init(style: UIAlertController.Style) {
        var style = style
        
        if style == .actionSheet && Constant.deviceType == .pad {
            style = .alert
        }
        
        self.alertController = UIAlertController(title: nil, message: nil, preferredStyle: style)
    }
    
    func setTitle(_ title: String) -> Self {
        alertController.title = title
        
        return self
    }
    
    func setMessage(_ message: String) -> Self {
        alertController.message = message
        
        return self
    }
    
    func setActions(_ actions: [AlertAction]) -> Self {
        actions.forEach {
            let action = UIAlertAction(title: $0.title, style: $0.style, handler: $0.handler)
            alertController.addAction(action)
        }
        
        return self
    }
    
    func setAction(title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        
        let action = UIAlertAction(title: title, style: style, handler: handler)
        
        alertController.addAction(action)
        
        return self
    }
    
    func endSet() -> UIAlertController {
        return alertController
    }
}
