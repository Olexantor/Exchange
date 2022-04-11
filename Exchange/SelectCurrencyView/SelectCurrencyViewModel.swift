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
//        let disposables = CompositeDisposable(disposables: [])
        var allViewModels = [CurrencyCellViewModel]()
        
        
        /*
        if let listOfCurrency = dependency.storageService.unloadCurrency() {
            allViewModels = createCellViewModels(for: listOfCurrency)
            filteredViewModels.accept(allViewModels)
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
                .emit(to: filteredViewModels)
            _ = disposables.insert(fetchCurrency)
        }
         */
        
        let fetchCurrency = dependency.storageService
            .loadCurrency()
            .subscribe {
                switch $0 {
                case .success(let listOfCurrency):
                    allViewModels = createCellViewModels(for: listOfCurrency)
                    filteredViewModels.accept(allViewModels)
                case .failure(let error):
                    print(error)
                    dependency.networkService
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
                        .emit(to: filteredViewModels)
                }
            }
        
        let isLoading = filteredViewModels
            .asDriver()
            .map { $0.isEmpty }
        
        let showError = didReceiveError
            .asSignal()
            .emit(onNext: { error in
                router.showAlert(with: error.description)
            })
        
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
