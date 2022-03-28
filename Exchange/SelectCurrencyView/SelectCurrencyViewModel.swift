//
//  SelectCurrencyViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

struct SelectCurrencyViewModel {
    let headerTitle: String
    let networkErrorInBox: Box<Error?>
    let cellViewModels: Box<[CurrencyCellViewModel]>
    let isIndicatorEnabled: Box<Bool>
}

extension SelectCurrencyViewModel: ViewModelType {
    struct Inputs {
        let title: String
        let onCompletion: (String) -> Void
    }
    
    final class Bindings {
        var didSelectCell: ((IndexPath) -> Void) = { _ in }
    }
    
    struct Dependencies {
        let networkService: NetworkManager
        let userDefaults: UserDefaults
    }
    
    typealias Routes = SelectCurrencyRouter
    
    static func configure(
        input: Inputs,
        binding: Bindings,
        dependency: Dependencies,
        router: Routes
    ) -> Self {
        func createCellViewModels(for currencies: [String]) -> [CurrencyCellViewModel] {
            var cellViewModels = [CurrencyCellViewModel]()
            currencies.forEach { currency in
                cellViewModels.append(CurrencyCellViewModel(currency: currency))
            }
            return cellViewModels
        }
        
        let networkErrorInBox = Box<Error?>(nil)
        let cellViewModels = Box<[CurrencyCellViewModel]>([])
        let isIndicatorEnabled = Box(true)

        var listOfCurrency = [String]() {
            didSet {
                cellViewModels.value = createCellViewModels(for: listOfCurrency)
                isIndicatorEnabled.value = false
            }
        }
        
        func getCurrencies() {
            let defaults = dependency.userDefaults
            if (defaults.object(forKey: "currencies") != nil) {
                listOfCurrency = defaults.object(forKey: "currencies") as? [String] ?? [String]()
            } else {
                dependency.networkService.fetchCurrencyList { result in
                    switch result {
                    case .success(let currencyList):
                        listOfCurrency = currencyList.data.map{ $0.key }.sorted()
                        defaults.set(listOfCurrency, forKey: "currencies")
                    case .failure(let error):
                        networkErrorInBox.value = error
                    }
                }
            }
        }
        getCurrencies()
        
        let headerTitle = input
            .title
            .uppercased()
        
        binding.didSelectCell = {
            input.onCompletion(cellViewModels.value[$0.row].currency)
            router.popViewController()
        }
        
        return .init(
            headerTitle: headerTitle,
            networkErrorInBox: networkErrorInBox,
            cellViewModels: cellViewModels,
            isIndicatorEnabled: isIndicatorEnabled
        )
    }
}

