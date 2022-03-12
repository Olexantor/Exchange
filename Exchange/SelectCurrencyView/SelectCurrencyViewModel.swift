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
    
    init(conditionOfButton: SelectButtonCondition) {
        self.conditionOfButton = conditionOfButton
        getCurrencies()
    }
    private var listOfCurrency = [String]() {
        didSet {
            currencyInBox.value = listOfCurrency
        }
    }
    private  var isFiltered = false
    private var filteredCurrency = [String]() {
        didSet {
            currencyInBox.value = filteredCurrency
        }
    }

    func numberOfRows() -> Int {
        if isFiltered {
            return filteredCurrency.count
        } else {
            return listOfCurrency.count
        }
    }
    
    func cellViewModel(forIndexPath indexPath: IndexPath) -> CurrencyCellViewModelType? {
        let currency: String
        if isFiltered {
            currency = filteredCurrency[indexPath.row]
        } else {
            currency = listOfCurrency[indexPath.row]
        }
        return CurrencyCellViewModel(currency: currency)
    }
    
    func filterDataWith(text: String, and condition: Bool) {
        isFiltered = condition
        filteredCurrency = listOfCurrency.filter{ $0.lowercased().contains(text.lowercased()) }
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
}

