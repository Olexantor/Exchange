//
//  CurrencyCellViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

final class CurrencyCellViewModel: CurrencyCellViewModelType {
    var currency: String
    
    init(currency: String) {
        self.currency = currency
    }
}

