//
//  SelectCurrencyViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

final class SelectCurrencyViewModel: SelectCurrencyViewModelType {
    var conditionOfButton: SelectButtonCondition
    
    init(conditionOfButton: SelectButtonCondition) {
        self.conditionOfButton = conditionOfButton
    }
    
    var listOfCurrency: [String] = []
    
    func getCurrencies() {
      
    }
}
