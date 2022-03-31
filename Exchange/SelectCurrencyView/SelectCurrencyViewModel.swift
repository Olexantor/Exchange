//
//  SelectCurrencyViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

struct SelectCurrencyViewModel {
    let networkErrorInBox: Box<Error?>
    let cellViewModels: Box<[CurrencyCellViewModel]>
    let isIndicatorEnabled: Box<Bool>
    
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
    
    final class Bindings {
        var didSelectCell: ((IndexPath) -> Void) = { _ in }
        var searchText: ((String) -> Void) = { _ in }
    }
    
    struct Dependencies {
        let networkService: NetworkManager
        let storageService: DataManagerType
    }
    
    typealias Routes = SelectCurrencyRouter
    
    static func configure(
        input: Inputs,
        binding: Bindings,
        dependency: Dependencies,
        router: Routes
    ) -> Self {
        let networkErrorInBox = Box<Error?>(nil)
        var allViewModels = [CurrencyCellViewModel]()
        let cellViewModels = Box<[CurrencyCellViewModel]>([])
        let isIndicatorEnabled = Box(true)
        
        //getting the list of currency cell view models
        if let listOfCurrency = dependency.storageService.unloadCurrency() {
            allViewModels = createCellViewModels(for: listOfCurrency)
            cellViewModels.value = allViewModels
            isIndicatorEnabled.value = false
        } else {
            dependency.networkService.fetchCurrencyList { result in
                switch result {
                case .success(let currencyList):
                    let listOfCurrency = currencyList.data.map{ $0.key }.sorted()
                    dependency.storageService.save(currency: listOfCurrency)
                    allViewModels = createCellViewModels(for: listOfCurrency)
                    cellViewModels.value = allViewModels
                    isIndicatorEnabled.value = false
                case .failure(let error):
                    networkErrorInBox.value = error
                }
            }
        }
        
        binding.didSelectCell = {
            input.didSelectCurrency(cellViewModels.value[$0.row].currency)
            router.popViewController()
        }
        
        binding.searchText = { text in
            if text.isEmpty {
                cellViewModels.value = allViewModels
            } else {
                cellViewModels.value = allViewModels
                    .filter {
                        $0.currency.lowercased()
                            .contains(text.lowercased())
                    }
            }
        }
        
        return .init(
            networkErrorInBox: networkErrorInBox,
            cellViewModels: cellViewModels,
            isIndicatorEnabled: isIndicatorEnabled
        )
    }
}

