//
//  DesignGuide.swift
//  MemoryCard
//
//  Created by yc on 1/14/24.
//

import UIKit

// MARK: - COLOR
extension UIColor {
	
	private static func getInterfaceColor(light: UIColor, dark: UIColor) -> UIColor {
		return UIColor { (traitCollection: UITraitCollection) -> UIColor in
			return traitCollection.userInterfaceStyle == .dark ? dark : light
		}
	}
	
	struct Text {
		static let point = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#A449FF"),
			dark: UIColor(hexCode: "#8A33CC")
		)
		static let heading = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#212121"),
			dark: UIColor(hexCode: "#E0E0E0")
		)
		static let `default` = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#424242"),
			dark: UIColor(hexCode: "#BDBDBD")
		)
		static let subdued = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#616161"),
			dark: UIColor(hexCode: "#B0B0B0")
		)
		static let disabled = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#9E9E9E"),
			dark: UIColor(hexCode: "#757575")
		)
		static let white = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#FFFFFF"),
			dark: UIColor(hexCode: "#121212")
		)
	}

	struct Background {
		static let primary = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#FAFAFA"),
			dark: UIColor(hexCode: "#2A2A2A")
		)
		static let secondary = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#FFFFFF"),
			dark: UIColor(hexCode: "#121212")
		)
	}

	struct Fill {
		static let point = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#A962FF"),
			dark: UIColor(hexCode: "#7F47CC")
		)
		static let tonal = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#F6E9FF"),
			dark: UIColor(hexCode: "#3F1A65")
		)
		static let navModal = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#FFFFFF"),
			dark: UIColor(hexCode: "#121212")
		)
		static let group01 = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#FFFFFF"),
			dark: UIColor(hexCode: "#121212")
		)
		static let group02 = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#FAFAFA"),
			dark: UIColor(hexCode: "#2A2A2A")
		)
		static let group03 = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#f5f5f5"),
			dark: UIColor(hexCode: "#444444")
		)
		static let group04 = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#E0E0E0"),
			dark: UIColor(hexCode: "#666666")
		)
		static let group05 = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#262626"),
			dark: UIColor(hexCode: "#BDBDBD")
		)
		static let speakComponent = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#8B8B8B33"),
			dark: UIColor(hexCode: "#5C5C5C33")
		)
		static let textField = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#f5f5f5"),
			dark: UIColor(hexCode: "#2A2A2A")
		)
		static let scrollbar = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#E0E0E0"),
			dark: UIColor(hexCode: "#666666")
		)
		static let moreModal = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#EFD4FF"),
			dark: UIColor(hexCode: "#6A2BFF")
		)
	}

	struct State {
		static let warning = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#EC0000"),
			dark: UIColor(hexCode: "#FF5722")
		)
	}

	struct Stroke {
		static let point = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#C362FF"),
			dark: UIColor(hexCode: "#9B4BFF")
		)
		static let subtle01 = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#EEEEEE"),
			dark: UIColor(hexCode: "#444444")
		)
		static let subtle02 = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#E0E0E0"),
			dark: UIColor(hexCode: "#555555")
		)
	}

	struct Button {
		static let primary = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#C362FF"),
			dark: UIColor(hexCode: "#9B4BFF")
		)
		static let primaryPress = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#7041C8"),
			dark: UIColor(hexCode: "#532B99")
		)
		static let tonal = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#DFD5FF"),
			dark: UIColor(hexCode: "#5C46C7")
		)
		static let disabled = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#EEEEEE"),
			dark: UIColor(hexCode: "#666666")
		)
	}

	struct MicState {
		static let `default` = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#8153DD"),
			dark: UIColor(hexCode: "#6A3EBF")
		)
		static let speaking = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#BA30FF"),
			dark: UIColor(hexCode: "#9A00D9")
		)
		static let complete = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#1DC373"),
			dark: UIColor(hexCode: "#0A8F4F")
		)
		static let alert = UIColor.getInterfaceColor(
			light: UIColor(hexCode: "#FF9852"),
			dark: UIColor(hexCode: "#FF7043")
		)
	}

	struct Dim {
		static let `default` = UIColor(hexCode: "#00000099")
		static let connecting = UIColor(hexCode: "#262626CC")
	}
	
	convenience init(hexCode: String, alpha: CGFloat? = nil) {
		var hexFormatted: String = hexCode.trimmingCharacters(
			in: CharacterSet.whitespacesAndNewlines
		).uppercased()
		
		if hexFormatted.hasPrefix("#") {
			hexFormatted = String(hexFormatted.dropFirst())
		}
		
		assert(hexFormatted.count == 6, "Invalid hex code used.")
		
		var rgbValue: UInt64 = 0
		Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
		
		self.init(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: alpha ?? 1.0
		)
	}
}

// MARK: - IMAGE
extension UIImage {
	
	struct System {
		
		static let house					= UIImage(systemName: "house")
		static let person					= UIImage(systemName: "person")
		static let xmark					= UIImage(systemName: "xmark")
		static let ear						= UIImage(systemName: "ear")
		static let stopFill					= UIImage(systemName: "stop.fill")
		static let arrowCounterclockwise	= UIImage(systemName: "arrow.counterclockwise")
		static let arrowRight				= UIImage(systemName: "arrow.right")
		static let arrowLeft				= UIImage(systemName: "arrow.left")
		static let mic						= UIImage(systemName: "mic")
		static let waveform					= UIImage(systemName: "waveform")
		static let handThumbsup				= UIImage(systemName: "hand.thumbsup")
		static let checkmark				= UIImage(systemName: "checkmark")
		static let play						= UIImage(systemName: "play")
		static let eye						= UIImage(systemName: "eye")
		static let eyeSlash					= UIImage(systemName: "eye.slash")
		static let pencilAndScribble		= UIImage(systemName: "pencil.and.scribble")
		static let qCircle					= UIImage(systemName: "q.circle")
		static let chevronRight2			= UIImage(systemName: "chevron.right.2")
		static let star						= UIImage(systemName: "star")
		static let starFill					= UIImage(systemName: "star.fill")
		static let questionmarkAppDashed	= UIImage(systemName: "questionmark.app.dashed")
		static let listBulletClipboard		= UIImage(systemName: "list.bullet.clipboard")
		static let jCircle					= UIImage(systemName: "j.circle")
		static let kCircle					= UIImage(systemName: "k.circle")
		static let eCircle					= UIImage(systemName: "e.circle")
		static let gearshape				= UIImage(systemName: "gearshape")
		static let logout					= UIImage(systemName: "rectangle.portrait.and.arrow.forward")
		static let crown					= UIImage(systemName: "crown")
		static let appBadge					= UIImage(systemName: "app.badge")
		static let questionmarkBubble		= UIImage(systemName: "questionmark.bubble")
		static let personSlash				= UIImage(systemName: "person.slash")
		static let bookmark					= UIImage(systemName: "bookmark")
		static let paintbrush				= UIImage(systemName: "paintbrush")
		static let plus						= UIImage(systemName: "plus")
		static let rotateArrow				= UIImage(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
		static let translate				= UIImage(systemName: "translate")
		static let trash					= UIImage(systemName: "trash")
		static let exchangeArrow			= UIImage(systemName: "arrow.left.and.line.vertical.and.arrow.right")
		
	}
}

// MARK: - FONT
extension UIFont {
	
	enum FontWeight: String {
		case bold		= "Pretendard-Bold"
		case medium		= "Pretendard-Medium"
		case regular	= "Pretendard-Regular"
	}
	
	private static func setPretendardFont(_ weight: FontWeight, size: CGFloat) -> UIFont {
		return UIFont(name: weight.rawValue, size: size)!
	}
	
	struct Pretendard {
		static func b(_ size: CGFloat) -> UIFont {
			return UIFont.setPretendardFont(.bold, size: size)
		}
		static let b32 = UIFont.setPretendardFont(.bold, size: 32)
		static let b24 = UIFont.setPretendardFont(.bold, size: 24)
		static let b20 = UIFont.setPretendardFont(.bold, size: 20)
		static let b18 = UIFont.setPretendardFont(.bold, size: 18)
		static let b16 = UIFont.setPretendardFont(.bold, size: 16)
		static let b14 = UIFont.setPretendardFont(.bold, size: 14)
		static let b12 = UIFont.setPretendardFont(.bold, size: 12)
		static let b10 = UIFont.setPretendardFont(.bold, size: 10)
		
		static func m(_ size: CGFloat) -> UIFont {
			return UIFont.setPretendardFont(.medium, size: size)
		}
		static let m32 = UIFont.setPretendardFont(.medium, size: 32)
		static let m24 = UIFont.setPretendardFont(.medium, size: 24)
		static let m20 = UIFont.setPretendardFont(.medium, size: 20)
		static let m18 = UIFont.setPretendardFont(.medium, size: 18)
		static let m16 = UIFont.setPretendardFont(.medium, size: 16)
		static let m14 = UIFont.setPretendardFont(.medium, size: 14)
		static let m12 = UIFont.setPretendardFont(.medium, size: 12)
		static let m10 = UIFont.setPretendardFont(.medium, size: 10)
		
		static func r(_ size: CGFloat) -> UIFont {
			return UIFont.setPretendardFont(.regular, size: size)
		}
		static let r32 = UIFont.setPretendardFont(.regular, size: 32)
		static let r24 = UIFont.setPretendardFont(.regular, size: 24)
		static let r20 = UIFont.setPretendardFont(.regular, size: 20)
		static let r18 = UIFont.setPretendardFont(.regular, size: 18)
		static let r16 = UIFont.setPretendardFont(.regular, size: 16)
		static let r14 = UIFont.setPretendardFont(.regular, size: 14)
		static let r12 = UIFont.setPretendardFont(.regular, size: 12)
		static let r10 = UIFont.setPretendardFont(.regular, size: 10)
	}
}
