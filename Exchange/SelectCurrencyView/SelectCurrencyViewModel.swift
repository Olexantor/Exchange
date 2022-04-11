//
//  SelectCurrencyViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation
import RxCocoa
import RxSwift

struct SelectCurrencyViewModel {
    let cellViewModels: Driver<[CurrencyCellViewModel]>
    let isLoading: Driver<Bool>
    let disposables: Disposable
    
    private static func createCellViewModels(for currencies: [String]) -> [CurrencyCellViewModel] {
        let cellViewModels = currencies.map {
            CurrencyCellViewModel(currency: $0)
        }
        return cellViewModels
    }
}

extension SelectCurrencyViewModel: ViewModelType {
    struct Inputs {
        let didSelectCurrency: (String) -> Void
    }
    
    struct Bindings {
        let didSelectCurrency: Signal<CurrencyCellViewModel>
        let searchText: Driver<String?>
    }
    
    struct Dependencies {
        let networkService: CurrencyService
        let storageService: DataManagerType
    }
    
    typealias Routes = SelectCurrencyRouter
    
    static func configure(
        input: Inputs,
        binding: Bindings,
        dependency: Dependencies,
        router: Routes
    ) -> Self {
        
        let filteredViewModels = BehaviorRelay<[CurrencyCellViewModel]>(value: [])
        let didReceiveError = PublishRelay<String>()
        var allViewModels = [CurrencyCellViewModel]()
        
       let loadedCurrency = dependency.networkService
             .fetchCurrencyList()
             .asDriver { error in
                 didReceiveError.accept(error.localizedDescription)
                 return .empty()
             }
             .map { currency -> [CurrencyCellViewModel] in
                 let currency = currency.data.map { $0.key }.sorted()
                 dependency.storageService.save(currency: currency )
                 allViewModels = createCellViewModels(for: currency)
                 return allViewModels
             }
        
        let fetchCurrency = dependency.storageService
            .getCurrency()
            .asDriver(onErrorJustReturn: [])
            .flatMap { listOfCurrency -> Driver<[CurrencyCellViewModel]> in
                if listOfCurrency.isEmpty {
                   return loadedCurrency
                } else {
                    return .just(createCellViewModels(for: listOfCurrency))
                }
            }
            .drive(filteredViewModels)

        
        let isLoading = filteredViewModels
            .asDriver()
            .map { $0.isEmpty }
        
        let showError = didReceiveError
            .asSignal()
            .emit(onNext: router.showAlert)
        
        let transferSelectedCurrency = binding
            .didSelectCurrency
            .emit(onNext: {
                input.didSelectCurrency($0.currency)
                router.popViewController()
            })
        
        let searchCurrency = binding
            .searchText
            .compactMap { $0 }
            .map { text -> [CurrencyCellViewModel] in
                guard !text.isEmpty else { return allViewModels }
                return allViewModels
                    .filter { $0.currency.lowercased().contains(text.lowercased())
                    }
            }
            .drive(filteredViewModels)
        
        let disposables = CompositeDisposable(
            fetchCurrency,
            showError,
            transferSelectedCurrency,
            searchCurrency
        )
        
        return .init(
            cellViewModels: filteredViewModels.asDriver(),
            isLoading: isLoading,
            disposables: disposables
        )
    }
}
