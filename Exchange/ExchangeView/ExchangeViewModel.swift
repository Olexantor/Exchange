//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import RxCocoa
import RxSwift

enum ButtonNumberInOrder {
    case first, second
}

struct ExchangeViewModel {
    let firstCurrencyInBox: Box<String>
    let secondCurrencyInBox: Box<String>
    let firstCurrencyCalculatedValueInBox: Box<String>
    let secondCurrencyCalculatedValueInBox: Box<String>
    let networkErrorInBox: Box<Error?>
    let disposables: Disposable
}

private extension ExchangeViewModel {
    private static var ratesForFirstCurrency = [String: Double]()
    private static var ratesForSecondCurrency = [String: Double]()
    
    private static func getRates(
        for currency: String,
        by buttonNumber: ButtonNumberInOrder,
        with dependency: Dependencies,
        and errorPlace: Box<Error?>
    ) {
        dependency.networkService.fetchExchangeRate(for: currency) { result in
            switch result {
            case .success(let currency):
                if buttonNumber == .first {
                    ratesForFirstCurrency = currency.rates
                } else {
                    ratesForSecondCurrency = currency.rates
                }
            case .failure(let error):
                errorPlace.value = error
            }
        }
    }
}

extension ExchangeViewModel: ViewModelType {
    struct Bindings {
        var didPressedSelectCurrenncyButton: (ButtonNumberInOrder) -> Void = { _ in}
        var didTapOnTextField: (TextFieldID) -> Void = { _ in }
        var textFieldDidChange: (TextFieldID, String) -> Void = { _,_  in }
        let didTapFirstCurrencySelectionButton: Signal<Void>
        let didTapSecondCurrencySelectionButton: Signal<Void>
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
        
        let firstButtonTap = binding.didTapFirstCurrencySelectionButton
            .emit(onNext: {
                router.showSelectCurrencyView {
                    firstCurrencyNameInBox.value = $0
                    getRates(for: $0, by: .first, with: dependency, and: networkError)
                }
            })
        
        let secondButtonTap = binding.didTapSecondCurrencySelectionButton
            .emit(onNext: {
                router.showSelectCurrencyView {
                    secondCurrencyNameInBox.value = $0
                    getRates(for: $0, by: .second, with: dependency, and: networkError)
                }
            })
        
    
//        binding.didPressedSelectCurrenncyButton = { buttonNumber in
//            switch buttonNumber {
//            case .first:
//                router.showSelectCurrencyView {
//                    firstCurrencyNameInBox.value = $0
//                    getRates(for: $0, by: .first, with: dependency, and: networkError)
//                }
//            case .second:
//                router.showSelectCurrencyView {
//                    secondCurrencyNameInBox.value = $0
//                    getRates(for: $0, by: .second, with: dependency, and: networkError)
//                }
//            }
//        }
        
//        binding.didTapOnTextField = {
//            switch $0 {
//            case .firstTF:
//                secondCurrencyCalculatedValue.value = ""
//            case .secondTF:
//                firstCurrencyCalculatedValue.value = ""
//            }
//        }
        
//        binding.textFieldDidChange = {
//            guard !firstCurrencyNameInBox.value.isEmpty && !secondCurrencyNameInBox.value.isEmpty else { return }
//            guard let value = Double($1) else { return }
//            switch $0 {
//            case .firstTF:
//                secondCurrencyCalculatedValue.value = String(
//                    format: "%0.2f",
//                    (value * Double(ratesForFirstCurrency[secondCurrencyNameInBox.value] ?? 0.0))
//                )
//            case .secondTF:
//                firstCurrencyCalculatedValue.value = String(
//                    format: "%0.2f",
//                    (value * Double(ratesForSecondCurrency[firstCurrencyNameInBox.value] ?? 0.0))
//                )
//            }
//        }
        let disposables = CompositeDisposable(
            firstButtonTap,
            secondButtonTap
        )
        
        return .init(
            firstCurrencyInBox: firstCurrencyNameInBox,
            secondCurrencyInBox: secondCurrencyNameInBox,
            firstCurrencyCalculatedValueInBox: firstCurrencyCalculatedValue,
            secondCurrencyCalculatedValueInBox: secondCurrencyCalculatedValue,
            networkErrorInBox: networkError,
            disposables: disposables
        )
    }
}
