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
//    let networkErrorInBox: Box<Error?>
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
        var didSelectCurrency: Signal<CurrencyCellViewModel>
//        var searchText: ((String) -> Void) = { _ in }
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
        var fetchCurrency: Disposable

        
        if let listOfCurrency = dependency.storageService.unloadCurrency() {
            cellViewModels.accept(createCellViewModels(for: listOfCurrency))
        } else {
            fetchCurrency = dependency
                .networkService
                .fetchCurrencyList()
                .delay(.seconds(3), scheduler: MainScheduler.instance)
                .asSignal { error in
                    didReceiveError.accept(error.localizedDescription)
                    return .empty()
                }
                .emit(onNext: {
                    let currency = $0.data.map { $0.key }.sorted()
                    dependency.storageService.save(currency: currency )
                    cellViewModels.accept(createCellViewModels(for: currency))
                })
        }
        
        let isLoading = cellViewModels
            .asDriver()
            .map { $0.isEmpty }
        
 
        
        let disposables = CompositeDisposable(
            disposables: [fetchCurrency]
        )
        
        return .init(
//            networkErrorInBox: networkErrorInBox,
            cellViewModels: cellViewModels.asDriver(),
            isLoading: isLoading,
            disposables: disposables
        )
    }
}















//        let networkErrorInBox = Box<Error?>(nil)
//        var allViewModels = [CurrencyCellViewModel]()
//        let cellViewModels = Box<[CurrencyCellViewModel]>([])
//        let isIndicatorEnabled = Box(true)

//getting the list of currency cell view models
/*
if let listOfCurrency = dependency.storageService.unloadCurrency() {
    allViewModels = createCellViewModels(for: listOfCurrency)
    cellViewModels.value = allViewModels
    isLoading.value = false
} else {
    dependency.networkService.fetchCurrencyList { result in
        switch result {
        case .success(let currencyList):
            let listOfCurrency = currencyList.data.map{ $0.key }.sorted()
            dependency.storageService.save(currency: listOfCurrency)
            allViewModels = createCellViewModels(for: listOfCurrency)
            cellViewModels.value = allViewModels
            isLoading.value = false
        case .failure(let error):
            networkErrorInBox.value = error
        }
    }
}
 */

//        binding.didSelectCell = {
//            input.didSelectCurrency(cellViewModels.value[$0.row].currency)
//            router.popViewController()
//        }

//        binding.searchText = { text in
//            if text.isEmpty {
//                cellViewModels.value = allViewModels
//            } else {
//                cellViewModels.value = allViewModels
//                    .filter {
//                        $0.currency.lowercased()
//                            .contains(text.lowercased())
//                    }
//            }
//        }
