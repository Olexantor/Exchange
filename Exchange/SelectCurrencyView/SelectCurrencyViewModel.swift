//
//  SelectCurrencyViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

final class SelectCurrencyViewModel: SelectCurrencyViewModelType {

    var conditionOfButton: SelectButtonCondition
    
    var networkErrorInBox: Box<Error?> = Box(nil)
    var currencyInBox: Box<[String]> = Box([])
    
    var delegate: SelectedCurrencyDelegate?
    
    private var listOfCurrency = [String]() {
        didSet {
            currencyInBox.value = listOfCurrency
        }
    }
    
    init(conditionOfButton: SelectButtonCondition) {
        self.conditionOfButton = conditionOfButton
        getCurrencies()
    }
    
    private func getCurrencies() {
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "currencies") != nil) {
            listOfCurrency = UserDefaults.standard.object(forKey: "currencies") as? [String] ?? [String]()
        } else {
            NetworkManager.shared.fetchCurrencyList { [weak self] result in
                switch result {
                case .success(let currencyList):
                    self?.listOfCurrency = currencyList.data.map{ $0.key }.sorted()
                    defaults.set(self?.listOfCurrency, forKey: "currencies")
                case .failure(let error):
                    self?.networkErrorInBox.value = error
                }
            }
        }
    }
    
    func numberOfRows() -> Int {
        listOfCurrency.count
    }
    
    func cellViewModel(forIndexPath indexPath: IndexPath) -> CurrencyCellViewModelType? {
        let currency = listOfCurrency[indexPath.row]
        return CurrencyCellViewModel(currency: currency)
    }
}
