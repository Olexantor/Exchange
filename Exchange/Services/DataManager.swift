//
//  DataManager.swift
//  Exchange
//
//  Created by Александр Николаев on 31.03.2022.
//

import Foundation

class DataManager: DataManagerType {
    static let shared = DataManager()
    private let defaults = UserDefaults.standard
    private init() {}
    
    func save(currency: [String]) {
        defaults.set(currency, forKey: Constants.keyForUserDef)
    }
    
    func unloadCurrency() -> [String]? {
        return defaults.stringArray(forKey: Constants.keyForUserDef)
    }
    
    func deleteCurrency() {
        defaults.removeObject(forKey: Constants.keyForUserDef)
    }
}

class FakeDataManager: DataManagerType {
    static let shared = FakeDataManager()
    private let defaults = UserDefaults.standard
    private init() {}
    
    func save(currency: [String]) {
    }
    
    func unloadCurrency() -> [String]? {
        return nil
    }
    
    func deleteCurrency() {
        defaults.removeObject(forKey: Constants.keyForUserDef)
    }
}
