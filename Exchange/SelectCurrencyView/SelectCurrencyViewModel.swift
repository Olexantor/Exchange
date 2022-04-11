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
        let searchCurrency: Driver<String?>
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
        
        let cellViewModels = BehaviorRelay<[CurrencyCellViewModel]>(value: [])
        let didReceiveError = PublishRelay<String>()
        let disposables = CompositeDisposable(disposables: [])
        var allViewModels = [CurrencyCellViewModel]()
        
        
        if let listOfCurrency = dependency.storageService.unloadCurrency() {
            allViewModels = createCellViewModels(for: listOfCurrency)
            cellViewModels.accept(allViewModels)
        } else {
            let fetchCurrency = dependency
                .networkService
                .fetchCurrencyList()
                .asSignal { error in
                    didReceiveError.accept(error.localizedDescription)
                    return .empty()
                }
                .map {
                    let currency = $0.data.map { $0.key }.sorted()
                    dependency.storageService.save(currency: currency )
                    allViewModels = createCellViewModels(for: currency)
                    return allViewModels
                }
                .emit(to: cellViewModels)
            _ = disposables.insert(fetchCurrency)
        }
        
        let isLoading = cellViewModels
            .asDriver()
            .map { $0.isEmpty }
        
        let showError = didReceiveError
            .asSignal()
            .emit(onNext: { _ in
                router.showAlert()
            })
        _ = disposables.insert(showError)
        
        let transferSelectedCurrency = binding
            .didSelectCurrency
            .emit(onNext: {
                input.didSelectCurrency($0.currency)
                router.popViewController()
            })
        _ = disposables.insert(transferSelectedCurrency)
        
        let searchCurrency = binding
            .searchCurrency
            .compactMap { $0 }
            .map { text -> [CurrencyCellViewModel] in
                guard !text.isEmpty else { return allViewModels }
                let filteredModels = allViewModels
                    .filter { $0.currency.lowercased().contains(text.lowercased())
                    }
                return filteredModels
            }
            .drive(cellViewModels)
        _ = disposables.insert(searchCurrency)
        
        return .init(
            cellViewModels: cellViewModels.asDriver(),
            isLoading: isLoading,
            disposables: disposables
        )
    }
}
