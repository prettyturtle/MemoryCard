//
//  UserDefaultsManager.swift
//  MemoryCard
//
//  Created by yc on 2023/07/17.
//

import Foundation

struct UserDefaultsManager<T: Codable & Equatable> {
    enum Key {
        case reminderList(mIdx: String)
        
        var value: String {
            switch self {
            case .reminderList(let mIdx):
                return "REMINDER_LIST_\(mIdx)"
            }
        }
    }
    
    let key: Key
    
    private let standard = UserDefaults.standard
    
    func read() -> [T]? {
        guard let savedData = standard.data(forKey: key.value) else {
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
    func save(_ newValue: T) -> [T]? {
        guard var savedList = read() else {
            return nil
        }
        
        savedList = savedList.filter { $0 != newValue }
        
        let newSavedList = savedList + [newValue]
        
        do {
            let newSavedData = try JSONEncoder().encode(newSavedList)
            
            standard.setValue(newSavedData, forKey: key.value)
            
            return newSavedList
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func update(_ newValue: T) -> [T]? {
        guard let savedList = read() else {
            return nil
        }
        
        let updatedSavedList = savedList.filter { $0 != newValue } + [newValue]
        
        do {
            let updatedSavedData = try JSONEncoder().encode(updatedSavedList)
            
            standard.setValue(updatedSavedData, forKey: key.value)
            
            return updatedSavedList
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func delete(_ value: T) -> [T]? {
        guard let saveList = read() else {
            return nil
        }
        
        let deletedSavedList = saveList.filter { $0 != value }
        
        do {
            let deletedSavedData = try JSONEncoder().encode(deletedSavedList)
            
            standard.setValue(deletedSavedData, forKey: key.value)
            
            return deletedSavedList
        } catch {
            return nil
        }
    }
}
