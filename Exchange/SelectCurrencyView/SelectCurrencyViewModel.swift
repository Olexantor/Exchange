//
//  SelectCurrencyViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

final class SelectCurrencyViewModel: SelectCurrencyViewModelType {

    var conditionOfButton: SelectButtonCondition
    
    var networkError: Box<Error?> = Box(nil)
    
    var listOfCurrency: Box<[String]> = Box([])
    
    init(conditionOfButton: SelectButtonCondition) {
        self.conditionOfButton = conditionOfButton
        getCurrencies()
    }
    
    func getCurrencies() {
        let defaults = UserDefaults.standard
        let array = ["hello", "world"]
        defaults.set(array, forKey: "Saved currencies")
        if (defaults.object(forKey: "Saved currencies") != nil) {
            listOfCurrency.value = UserDefaults.standard.object(forKey: "Saved currencies") as? [String] ?? [String]()
        } else {
            NetworkManager.shared.fetchCurrencyList { [weak self] result in
                switch result {
                case .success(let currencyList):
                    self?.listOfCurrency.value = currencyList.data.map{ $0.key }.sorted()
                    defaults.set(self?.listOfCurrency, forKey: "Saved currencies")
                case .failure(let error):
                    self?.networkError.value = error
                }
            }
        }
    }
    
    func numberOfRows() -> Int {
        listOfCurrency.value.count
    }
    
    func cellViewModel(forIndexPath indexPath: IndexPath) -> CurrencyCellViewModelType? {
        let currency = listOfCurrency.value[indexPath.row]
        return CurrencyCellViewModel(currency: currency)
    }
}
