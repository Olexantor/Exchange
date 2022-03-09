//
//  ExchangeRates.swift
//  Exchange
//
//  Created by Александр on 08.03.2022.
//

import Foundation

struct ExchangedRates: Decodable {
        let currencies: [String: String]
}
