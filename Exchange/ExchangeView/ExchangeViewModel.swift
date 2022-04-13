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
        let firstCurrency = BehaviorRelay<String>(value: "")
        let secondCurrency = BehaviorRelay<String>(value: "")
        let ratesForFirstCurrency = BehaviorRelay<Dictionary<String, Double>>(value: [:])
        let ratesForSecondCurrency = BehaviorRelay<Dictionary<String, Double>>(value: [:])
        let textOfFirstCurrencyTextField = BehaviorRelay<String>(value: "")
        let textOfSecondCurrencyTextField =  BehaviorRelay<String>(value: "")
        
        let firstButtonTapDisposable = binding.didTapFirstCurrencySelectionButton
            .emit { _ in
                router.showSelectCurrencyView {
                    firstCurrency.accept($0)
                }
            }
        
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
            .emit { _ in
                router.showSelectCurrencyView {
                    secondCurrency.accept($0)
                }
            }
        
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
            .compactMap { $0 }
            .drive(onNext: {
                guard !firstCurrency.value.isEmpty && !secondCurrency.value.isEmpty else { return }
                guard let value = Double($0) else { return }
                textOfSecondCurrencyTextField.accept(
                    String(
                        format: "%0.2f",
                        (value * Double(ratesForFirstCurrency.value[secondCurrency.value] ?? 0.0))
                    )
                )
            })
        
        let secondTextFieldDisposable = binding.textOfSecondCurrencyTextField
            .compactMap { $0 }
            .drive(onNext: {
                guard !firstCurrency.value.isEmpty && !secondCurrency.value.isEmpty else { return }
                guard let value = Double($0) else { return }
                textOfFirstCurrencyTextField.accept(
                    String(
                        format: "%0.2f",
                        (value * Double(ratesForSecondCurrency.value[firstCurrency.value] ?? 0.0))
                    )
                )
            })
        
        let showErrorDisposable = didReceiveError
            .asSignal()
            .emit { error in
                router.showAlert(with: error)
            }
        
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
