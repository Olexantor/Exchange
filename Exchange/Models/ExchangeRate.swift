//
//  ExchangeRate.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

struct ExchangeRate {
    var rates = [String: Double]()
    
    init?(data: CurrenciesList) {
        data.data.forEach { (key: String, value: Datum) in
            rates[value.code] = value.value
        }
    }
}
