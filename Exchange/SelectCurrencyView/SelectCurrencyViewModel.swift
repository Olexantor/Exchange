//
//  SelectCurrencyViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

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
        let didSelectCurrency: (String) -> (Void)
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
        
        let didReceiveError = PublishRelay<String>()
        
        let loadedCurrency = dependency.networkService
            .fetchCurrencyList()
            .map { currency -> [CurrencyCellViewModel] in
                let currency = currency.data.map { $0.key }.sorted()
                dependency.storageService.save(currency: currency )
                return createCellViewModels(for: currency)
            }
        
        let viewModels = dependency
            .storageService
            .getCurrency()
            .catchAndReturn([])
            .flatMap { listOfCurrency -> Single<[CurrencyCellViewModel]> in
                if listOfCurrency.isEmpty {
                    return loadedCurrency
                } else {
                    return .just(createCellViewModels(for: listOfCurrency))
                }
            }
            .asDriver { error in
                didReceiveError.accept(error.localizedDescription)
                return .empty()
            }
        
        let showErrorDisposable = didReceiveError
            .asSignal()
            .emit { error in
                router.showAlert(with: error)
            }

        let isLoading = viewModels
            .asDriver()
            .map { $0.isEmpty }
        
        let transferSelectedCurrencyDisposable = binding
            .didSelectCurrency
            .emit(onNext: {
                input.didSelectCurrency($0.currency)
                router.popViewController()
            })
        
        let filteredViewModels = Driver
            .combineLatest(
                viewModels,
                binding.searchText
            ) { viewModels, searchText -> [CurrencyCellViewModel] in
                guard let searchText = searchText, !searchText.isEmpty else {
                    return viewModels
                }
                return viewModels.filter { $0.currency.lowercased().contains(searchText.lowercased())
                }
            }
         
        let disposables = CompositeDisposable(
            showErrorDisposable,
            transferSelectedCurrencyDisposable
        )
        
        return .init(
            cellViewModels: filteredViewModels.asDriver(),
            isLoading: isLoading,
            disposables: disposables
        )
    }
}
