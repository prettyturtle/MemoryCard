//
//  Util.swift
//  MemoryCard
//
//  Created by yc on 7/25/24.
//

import Foundation

struct UpdateVersion: Decodable {
	let version			: Double
	let storeURL		: String
	let alertTitle		: String
	let alertMessage	: String
}
