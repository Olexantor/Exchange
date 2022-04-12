//
//  CurrencyService.swift
//  Exchange
//
//  Created by Александр Николаев on 08.04.2022.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

struct CurrencyService {
    func fetchCurrencyList() -> Single<CurrenciesList> {
        let url = URL(string: Constants.currencyUrlString)!
        let request = URLRequest(url: url )
        
        return URLSession.shared.rx
            .data(request: request)
            .map { try JSONDecoder().decode(CurrenciesList.self, from: $0) }
            .asSingle()
    }
    
    func fetchExchangeRate(for base: String) -> Single<ExchangeRate> {
        let url = URL(string: Constants.convertUrlString+base)!
        let request = URLRequest(url: url )
        
        return URLSession.shared.rx
            .data(request: request)
            .map { try JSONDecoder().decode(CurrenciesList.self, from: $0) }
            .compactMap { ExchangeRate(data: $0) }
            .asSingle()
    }
}
