//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import RxCocoa
import RxSwift

struct ExchangeViewModel {
    let firstCurrency: Driver<String>
    let secondCurrency: Driver<String>
    let firstCurrencyCalculatedValue: Driver<String>
    let secondCurrencyCalculatedValue: Driver<String>
    let disposables: Disposable
}

extension ExchangeViewModel: ViewModelType {
    struct Bindings {
        let didTapFirstCurrencySelectionButton: Signal<Void>
        let didTapSecondCurrencySelectionButton: Signal<Void>
        let textOfFirstCurrencyTextField: Driver<String?>
        let textOfSecondCurrencyTextField: Driver<String?>
    }
    
    struct Dependencies {
        let networkService: CurrencyService
    }
    
    typealias Routes = ExchangeViewRouter
    
    static func configure(
        input: Inputs,
        binding: Bindings,
        dependency: Dependencies,
        router: Routes
    ) -> Self {
        
        let didReceiveError = PublishRelay<String>()
        
        let firstСhosenСurrency = binding.didTapFirstCurrencySelectionButton
            .flatMap(router.showSelectCurrencyViewController)
            .asDriver(onErrorJustReturn: "")
        
        let firstCurrencyRates = firstСhosenСurrency
            .asObservable()
            .flatMapLatest { currency -> Single<ExchangeRate> in
                dependency
                    .networkService
                    .fetchExchangeRate(for: currency)
            }
            .map { $0.rates }
            .asDriver { error in
                didReceiveError.accept(error.localizedDescription)
                return .empty()
            }
        
        let secondChosenCurrency = binding.didTapSecondCurrencySelectionButton
            .flatMap(router.showSelectCurrencyViewController)
            .asDriver(onErrorJustReturn: "")
        
        let secondCurrencyRates = secondChosenCurrency
            .asObservable()
            .flatMapLatest { currency -> Single<ExchangeRate> in
                dependency
                    .networkService
                    .fetchExchangeRate(for: currency)
            }
            .map { $0.rates }
            .asDriver { error in
                didReceiveError.accept(error.localizedDescription)
                return .empty()
            }
        
        let firstCurrencyCalculatedValue = Driver.combineLatest(
            firstСhosenСurrency,
            binding.textOfSecondCurrencyTextField,
            firstCurrencyRates,
            secondCurrencyRates
        ) {
            firstCurrency, text, ratesOfFirstCurrency, ratesOfSecondCurrency -> String in
            guard !ratesOfFirstCurrency.isEmpty && !ratesOfSecondCurrency.isEmpty else {
                return String()
            }
            guard let text = text, let number = Double(text) else { return String() }
            return String(
                format: "%0.2f",
                (number * Double(ratesOfSecondCurrency[firstCurrency] ?? 0.0))
            )
        }
        
        let secondCurrencyCalculatedValue = Driver.combineLatest(
            secondChosenCurrency,
            binding.textOfFirstCurrencyTextField,
            firstCurrencyRates,
            secondCurrencyRates
        ) {
            secondCurrency, text, ratesOfFirstCurrency, ratesOfSecondCurrency -> String in
            guard !ratesOfFirstCurrency.isEmpty && !ratesOfSecondCurrency.isEmpty else {
                return String()
            }
            guard let text = text, let number = Double(text) else { return String() }
            return String(
                format: "%0.2f",
                (number * Double(ratesOfFirstCurrency[secondCurrency] ?? 0.0))
            )
        }
        
        let showErrorDisposable = didReceiveError
            .asSignal()
            .emit(onNext: router.showAlert)
        
        return .init(
            firstCurrency: firstСhosenСurrency,
            secondCurrency: secondChosenCurrency,
            firstCurrencyCalculatedValue: firstCurrencyCalculatedValue,
            secondCurrencyCalculatedValue: secondCurrencyCalculatedValue,
            disposables: showErrorDisposable
        )
    }
}
