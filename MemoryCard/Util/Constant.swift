//
//  Constant.swift
//  MemoryCard
//
//  Created by yc on 2023/03/25.
//

import UIKit

struct Constant {
    static var defaultInset: Float {
        return 16.0
    }
    static var pushToken: String?
    
    static var deviceType: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }
}

let CARD_START_STATE                                = "CARD_START_STATE"
let IS_DONE_TUTORIAL_INTRO                          = "IS_DONE_TUTORIAL_INTRO"
let IS_DONE_TUTORIAL_CREATE_CARD_FOLDER_NAME_INPUT  = "IS_DONE_TUTORIAL_CREATE_CARD_FOLDER_NAME_INPUT"
let IS_DONE_TUTORIAL_CREATE_CARD_CONTENT_INPUT      = "IS_DONE_TUTORIAL_CREATE_CARD_CONTENT_INPUT"
let APP_ICON                                        = "APP_ICON"
let IS_ALLOW_REMINDER_NOTI                          = "IS_ALLOW_REMINDER_NOTI"
let AUTO_PLAY_SPEED                                 = "AUTO_PLAY_SPEED"
