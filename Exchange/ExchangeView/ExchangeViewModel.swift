//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import UIKit

struct ExchangeViewModel {
    let firstCurrencyInBox: Box<String>
    let secondCurrencyInBox: Box<String>
    let firstCurrencyCalculatedValueInBox: Box<String>
    let secondCurrencyCalculatedValueInBox: Box<String>
    let networkErrorInBox: Box<Error?>
    private static var ratesForFirstCurrency = [String: Double]()
    private static var ratesForSecondCurrency = [String: Double]()
}

extension ExchangeViewModel: ViewModelType {
    final class Bindings {
        var didPressedSelectCurrenncyButton: (ButtonNumberInOrder) -> Void = { _ in}
        var didTapOnTextField: (TextFieldID) -> Void = { _ in }
        var textFieldDidChange: (TextFieldID, UITextField) -> Void = { _,_  in }
    }
    
    struct Dependencies {
        let networkService: NetworkManager
    }
    
    typealias Routes = ExchangeViewRouter
    
    static func configure(
        input: Inputs,
        binding: Bindings,
        dependency: Dependencies,
        router: Routes
    ) -> Self {
        
        let firstCurrencyNameInBox = Box<String>("")
        let secondCurrencyNameInBox = Box<String>("")
        let firstCurrencyCalculatedValue = Box<String>("")
        let secondCurrencyCalculatedValue =  Box<String>("")
        let networkError = Box<Error?>(nil)
        
        func getRates(for currency: String, by buttonNumber: ButtonNumberInOrder) {
            dependency.networkService.fetchExchangeRate(for: currency) { result in
                switch result {
                case .success(let currency):
                    if buttonNumber == .first {
                        ratesForFirstCurrency = currency.rates
                    } else {
                        ratesForSecondCurrency = currency.rates
                    }
                case .failure(let error):
                    networkError.value = error
                }
            }
        }
        
        binding.didPressedSelectCurrenncyButton = { buttonNumber in
            switch buttonNumber {
            case .first:
                router.showSelectCurrencyView {
                    firstCurrencyNameInBox.value = $0
                    getRates(for: $0, by: buttonNumber)
                }
            case .second:
                router.showSelectCurrencyView {
                    secondCurrencyNameInBox.value = $0
                    getRates(for: $0, by: buttonNumber)
                }
            }
        }
        
        binding.didTapOnTextField = { textFieldID in
            switch textFieldID {
            case .firstTF:
                secondCurrencyCalculatedValue.value = ""
            case .secondTF:
                firstCurrencyCalculatedValue.value = ""
            }
        }
        
        binding.textFieldDidChange = {
            guard !firstCurrencyNameInBox.value.isEmpty && !secondCurrencyNameInBox.value.isEmpty else { return }
            guard let text = $1.text, let value = Double(text) else { return }
            switch $0 {
            case .firstTF:
                secondCurrencyCalculatedValue.value = String(
                    format: "%0.2f",
                    (value * Double(ratesForFirstCurrency[secondCurrencyNameInBox.value] ?? 0.0))
                )
            case .secondTF:
                firstCurrencyCalculatedValue.value = String(
                    format: "%0.2f",
                    (value * Double(ratesForSecondCurrency[firstCurrencyNameInBox.value] ?? 0.0))
                )
            }
        }
        
        return .init(
            firstCurrencyInBox: firstCurrencyNameInBox,
            secondCurrencyInBox: secondCurrencyNameInBox,
            firstCurrencyCalculatedValueInBox: firstCurrencyCalculatedValue,
            secondCurrencyCalculatedValueInBox: secondCurrencyCalculatedValue,
            networkErrorInBox: networkError
        )
    }
}
