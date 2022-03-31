//
//  DataManagerType.swift
//  Exchange
//
//  Created by Александр Николаев on 31.03.2022.
//

import Foundation

protocol DataManagerType {
    func save(currency: [String])
    func unloadCurrency() -> [String]?
    func deleteCurrency()
}
