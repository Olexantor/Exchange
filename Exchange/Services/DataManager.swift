//
//  DataManager.swift
//  Exchange
//
//  Created by Александр Николаев on 31.03.2022.
//

import Foundation
import RxCocoa
import RxSwift

enum UDError: Error {
    case doesNotExist
}

class DataManager: DataManagerType {
    static let shared = DataManager()
    private let defaults = UserDefaults.standard
    private init() {}
    
    func save(currency: [String]) {
        defaults.set(currency, forKey: Constants.keyForUserDef)

    }
    
//    func unloadCurrency() -> Single<[String]?> {
//      return defaults.stringArray(forKey: Constants.keyForUserDef)
//        return defaults.rx.observe(Array<String>.self, Constants.keyForUserDef)
//            .asSingle()
//    }
    
    func loadCurrency() -> Single<[String]> {
        return Single.create { [self] single in
            let disposable = Disposables.create()
            
            guard let content = defaults.stringArray(forKey: Constants.keyForUserDef) else {
                single(.failure(UDError.doesNotExist))
                return disposable
            }
            single(.success(content))
            return disposable
        }
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
    
    func loadCurrency() -> Single<[String]>  {
        return Single.create { single in
            let disposable = Disposables.create()
            single(.failure(UDError.doesNotExist))
            return disposable
        }
    }
    
    func deleteCurrency() {
        defaults.removeObject(forKey: Constants.keyForUserDef)
    }
}

