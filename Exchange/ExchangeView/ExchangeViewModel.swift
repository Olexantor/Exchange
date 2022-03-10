//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

final class ExchangeViewModel: ExchangeViewModelType {
    
    var fromCurrencyName = ""
    
    var intoCurrencyName = ""
    
    var fromCurrencyValue = 0.0
    
    var intoCurrencyValue = 0.0
    
    func viewModelWithSelected(condition: SelectButtonCondition) -> SelectCurrencyViewModelType? {
        return SelectCurrencyViewModel(conditionOfButton: condition)
    }
}
