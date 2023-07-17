//
//  UserDefaultsManager.swift
//  MemoryCard
//
//  Created by yc on 2023/07/17.
//

import Foundation

struct UserDefaultsManager<T: Codable & Equatable> {
    
    private let standard = UserDefaults.standard
    
    let key: String
    
    func read() -> [T]? {
        guard let savedData = standard.data(forKey: key) else {
            return []
        }
        
        do {
            let savedValueList = try JSONDecoder().decode([T].self, from: savedData)
            return savedValueList
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func save(_ newValue: T) -> Bool {
        guard let savedList = read() else {
            return false
        }
        
        let newSavedList = savedList + [newValue]
        
        do {
            let newSavedData = try JSONEncoder().encode(newSavedList)
            
            standard.setValue(newSavedData, forKey: key)
            
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult
    func update(_ newValue: T) -> Bool {
        guard let savedList = read() else {
            return false
        }
        
        let updatedSavedList = savedList.filter { $0 != newValue } + [newValue]
        
        do {
            let updatedSavedData = try JSONEncoder().encode(updatedSavedList)
            
            standard.setValue(updatedSavedData, forKey: key)
            
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult
    func delete(_ value: T) -> Bool {
        guard let saveList = read() else {
            return false
        }
        
        let deletedSavedList = saveList.filter { $0 != value }
        
        do {
            let deletedSavedData = try JSONEncoder().encode(deletedSavedList)
            
            standard.setValue(deletedSavedData, forKey: key)
            
            return true
        } catch {
            return false
        }
    }
}
