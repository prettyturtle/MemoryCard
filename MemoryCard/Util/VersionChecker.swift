//
//  VersionChecker.swift
//  MemoryCard
//
//  Created by yc on 2023/11/20.
//

import Foundation

struct VersionChecker {
    static func getCurrentVersion() async -> String? {
        let bundleIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"]
        
        guard let bundleID = bundleIdentifier as? String else {
            return nil
        }
        
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleID)"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        var data: Data
        
        do {
            let (apiData, _) = try await URLSession.shared.data(from: url)
            
            data = apiData
        } catch {
            return nil
        }
        
        var currentVersion: String
        
        do {
            guard let jsonObj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = jsonObj["results"] as? [[String: Any]],
                  let version = results.first?["version"] as? String else {
                return nil
            }
            
            currentVersion = version
        } catch {
            return nil
        }
        
        return currentVersion
    }
    
    static func compareVersion(current: String, store: String) -> Bool {
        var currentVersionNums = current.split(separator: ".").compactMap { Int(String($0)) }
        var storeVersionNums = store.split(separator: ".").compactMap { Int(String($0)) }
        
        if currentVersionNums.count < 3 {
            while currentVersionNums.count != 3 {
                currentVersionNums.append(0)
            }
        }
        
        if storeVersionNums.count < 3 {
            while storeVersionNums.count != 3 {
                storeVersionNums.append(0)
            }
        }
        
        if currentVersionNums[0] < storeVersionNums[0] {
            return true
        }
        
        if currentVersionNums[1] < storeVersionNums[1] {
            return true
        }
        
        if currentVersionNums[2] < storeVersionNums[2] {
            return true
        }
        
        return false
    }
}
