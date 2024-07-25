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
	
	static var appVersion: Double? {
		guard let verStr = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
			return nil
		}
		
		return Double(verStr)
	}
}

let CARD_START_STATE								= "CARD_START_STATE"
let IS_DONE_TUTORIAL_INTRO							= "IS_DONE_TUTORIAL_INTRO"
let IS_DONE_TUTORIAL_CREATE_CARD_FOLDER_NAME_INPUT	= "IS_DONE_TUTORIAL_CREATE_CARD_FOLDER_NAME_INPUT"
let IS_DONE_TUTORIAL_CREATE_CARD_CONTENT_INPUT		= "IS_DONE_TUTORIAL_CREATE_CARD_CONTENT_INPUT"
let APP_ICON										= "APP_ICON"
let IS_ALLOW_REMINDER_NOTI							= "IS_ALLOW_REMINDER_NOTI"
let AUTO_PLAY_SPEED									= "AUTO_PLAY_SPEED"
let IS_TAPPED_PUSH_ALLOW							= "IS_TAPPED_PUSH_ALLOW"

let GAME_MODE_OPTIONS								= "GAME_MODE_OPTIONS"
