//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

enum SaveLocation {
    case firstDictionary, secondDictionary
}

import Foundation
protocol SelectedCurrencyDelegate: AnyObject {
    func selectedCurrencyWith(currencyName: String, and condition: SelectButtonCondition)
}

final class ExchangeViewModel: ExchangeViewModelType, SelectedCurrencyDelegate, ViewModelType {

    struct Inputs{
        let title: String
    }
    
    struct Dependencies {
        let networkService: NetworkManager
    }
    
    typealias Routes = ExchangeViewRouter
    
    let headerTitle: String
    
    static func configure(
        input: Inputs,
        binding: (),
        dependency: Dependencies,
        router: Routes
    ) -> ExchangeViewModel {
        
        let headerTitle = input
            .title
            .uppercased()
        
        return ExchangeViewModel()
    }

    
    var firstCurrencyNameInBox: Box<String> = Box("")
    var secondCurrencyNameInBox: Box<String> = Box("")
    var firstCurrencyCalculatedValueInBox: Box<String> = Box("")
    var secondCurrencyCalculatedValueInBox: Box<String> = Box("")
    var networkErrorInBox: Box<Error?> = Box(nil)
    var saveLocation: SaveLocation?
    var ratesForFirstCurrency = [String: Double]()
    var ratesForSecondCurrency = [String: Double]()
    
    func viewModelWithSelected(condition: SelectButtonCondition) -> SelectCurrencyViewModelType? {
        return SelectCurrencyViewModel(conditionOfButton: condition)
    }
    
    func selectedCurrencyWith(
        currencyName: String,
        and condition: SelectButtonCondition
    ) {
        switch condition {
        case .firstButton:
            firstCurrencyNameInBox.value = currencyName
        case .secondButton:
            secondCurrencyNameInBox.value = currencyName
        }
    }
    
    func clearingTheFieldFor(textFieldID: TextFieldID) {
        switch textFieldID {
        case .firstTF:
            secondCurrencyCalculatedValueInBox.value = ""
        case .secondTF:
            firstCurrencyCalculatedValueInBox.value = ""
        }
    }
    
    func getCurrencyRates(
        for currency: String,
        with saveLocation: SaveLocation?
    ) {
        guard let saveLocation = saveLocation else {
            return
        }
        NetworkManager.shared.fetchExchangeRate(with: currency) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let rate):
                if saveLocation == .firstDictionary {
                    self.ratesForFirstCurrency = rate.rates
                } else {
                    self.ratesForSecondCurrency = rate.rates
                }
            case .failure(let error):
                self.networkErrorInBox.value = error
            }
        }
    }
    
    func calculateValueFor(for value: String, from textField: TextFieldID) {
        guard !firstCurrencyNameInBox.value.isEmpty && !secondCurrencyNameInBox.value.isEmpty else { return }
        guard let value = Double(value) else { return }
        switch textField {
        case .firstTF:
            secondCurrencyCalculatedValueInBox.value = String(format: "%0.2f", (value * Double(ratesForFirstCurrency[secondCurrencyNameInBox.value] ?? 0.0)) )
        case .secondTF:
            firstCurrencyCalculatedValueInBox.value = String(format: "%0.2f", (value * Double(ratesForSecondCurrency[firstCurrencyNameInBox.value] ?? 0.0)) )
        }
    }
}
