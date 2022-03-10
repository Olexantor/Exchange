//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation
protocol SelectedCurrencyDelegate: AnyObject {
    func selectedCurrencyWith(currencyName: String, and condition: SelectButtonCondition)
}

final class ExchangeViewModel: ExchangeViewModelType, SelectedCurrencyDelegate {
    
    var fromCurrencyName: Box<String> = Box("")
    
    var intoCurrencyName: Box<String> = Box("")
    
    var fromCurrencyValue = 0.0
    
    var intoCurrencyValue = 0.0
    
//    func getCurrencies() {
//        let defaults = UserDefaults.standard
//        if (defaults.object(forKey: "!") != nil) {
//            listOfCurrency = UserDefaults.standard.object(forKey: "!") as? [String] ?? [String]()
//        } else {
//            NetworkManager.shared.fetchCurrencyList { [weak self] result in
//                switch result {
//                case .success(let currencyList):
//                        self?.listOfCurrency = currencyList.data.map{ $0.key }.sorted()
//                    defaults.set(self?.listOfCurrency, forKey: "!")
//                case .failure(let error):
//                    self?.networkError.value = error
//                }
//            }
//        }
//    }
    
    func viewModelWithSelected(condition: SelectButtonCondition) -> SelectCurrencyViewModelType? {
        return SelectCurrencyViewModel(conditionOfButton: condition)
    }
    
    func selectedCurrencyWith(currencyName: String, and condition: SelectButtonCondition) {
        switch condition {
        case .firstButton:
            fromCurrencyName.value = currencyName
        case .secondButton:
            intoCurrencyName.value = currencyName
        }
    }
    
}
