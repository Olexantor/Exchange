//
//  ExchangeRates.swift
//  Exchange
//
//  Created by Александр on 08.03.2022.
//

struct CurrenciesList: Decodable {
    let data: [String: Datum]
}

struct Datum: Decodable {
    let code: String
    let value: Double
}

