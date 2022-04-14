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
        let firstCurrency = BehaviorRelay(value: "")
        let secondCurrency = BehaviorRelay(value: "")
        let ratesForFirstCurrency = BehaviorRelay(value: [String:Double]())
        let ratesForSecondCurrency = BehaviorRelay(value: [String:Double]())
        let textOfFirstCurrencyTextField = BehaviorRelay(value: "")
        let textOfSecondCurrencyTextField =  BehaviorRelay(value: "")
        
        let firstButtonTapDisposable = binding.didTapFirstCurrencySelectionButton
            .flatMap { _ in
                router.showSelectCurrencyViewController()
            }
            .emit(to: firstCurrency)
        
        let firstCurrencyRatesDisposable = firstCurrency
            .skip(1)
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
            .drive(ratesForFirstCurrency)
        
        let secondButtonTapDisposable = binding.didTapSecondCurrencySelectionButton
            .flatMap(router.showSelectCurrencyViewController)
            .emit(to: secondCurrency)
        
        let secondCurrencyRatesDisposable = secondCurrency
            .skip(1)
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
            .drive(ratesForSecondCurrency)
        
        let firstTextFieldDisposable = binding.textOfFirstCurrencyTextField
            .skip(1)
            .compactMap { $0 }
            .map {
                guard !firstCurrency.value.isEmpty && !secondCurrency.value.isEmpty else {
                    return Double()
                }
                guard let value = Double($0) else { return Double() }
                return value
            }
            .map {
                String(
                    format: "%0.2f",
                    ($0 * Double(ratesForFirstCurrency.value[secondCurrency.value] ?? 0.0))
                )
            }
            .drive(textOfSecondCurrencyTextField)
        
        let secondTextFieldDisposable = binding.textOfSecondCurrencyTextField
            .skip(1)
            .compactMap { $0 }
            .map {
                guard !firstCurrency.value.isEmpty && !secondCurrency.value.isEmpty else {
                    return Double()
                }
                guard let value = Double($0) else { return Double() }
                return value
            }
            .map {
                String(
                    format: "%0.2f",
                    ($0 * Double(ratesForSecondCurrency.value[firstCurrency.value] ?? 0.0))
                )
            }
            .drive(textOfFirstCurrencyTextField)
        
        let showErrorDisposable = didReceiveError
            .asSignal()
            .emit(onNext: router.showAlert)
        
        let disposables = CompositeDisposable(
            firstButtonTapDisposable,
            firstCurrencyRatesDisposable,
            secondButtonTapDisposable,
            secondCurrencyRatesDisposable,
            firstTextFieldDisposable,
            secondTextFieldDisposable,
            showErrorDisposable
        )
        
        return .init(
            firstCurrency: firstCurrency.asDriver(),
            secondCurrency: secondCurrency.asDriver(),
            firstCurrencyCalculatedValue: textOfFirstCurrencyTextField.asDriver(),
            secondCurrencyCalculatedValue: textOfSecondCurrencyTextField.asDriver(),
            disposables: disposables)
    }
}
