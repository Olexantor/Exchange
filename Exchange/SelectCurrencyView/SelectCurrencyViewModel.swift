//
//  SelectCurrencyViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

struct SelectCurrencyViewModel: SelectCurrencyViewModelType  {
    let headerTitle: String


    var networkErrorInBox: Box<Error?>
    var currencyInBox: Box<[String]>

    var listOfCurrency: [String]
    
    var cellViewModels:[CurrencyCellViewModel]
    
//    var viewForCell: (IndexPath) -> CurrencyCellViewModel
    

//    private var listOfCurrency = [String]() {
//        didSet {
//            currencyInBox.value = listOfCurrency
//        }
//    }
//    private  var isFiltered = false
//    private var filteredCurrency = [String]() {
//        didSet {
//            currencyInBox.value = filteredCurrency
//        }
//    }

//    func numberOfRows() -> Int {
//        if isFiltered {
//            return filteredCurrency.count
//        } else {
//            return listOfCurrency.count
//        }
//    }
    
    func cellViewModel(forIndexPath indexPath: IndexPath) -> CurrencyCellViewModelType? {
        let currency: String
//        if isFiltered {
//            currency = filteredCurrency[indexPath.row]
//        } else {
            currency = listOfCurrency[indexPath.row]
//        }
        return CurrencyCellViewModel(currency: currency)
    }
    
    func createCellViewModels(for currencies: [String]) -> [CurrencyCellViewModel] {
        var cellViewModels = [CurrencyCellViewModel]()
        currencies.forEach { currency in
            cellViewModels.append(CurrencyCellViewModel(currency: currency))
        }
        return cellViewModels
    }
    
//    mutating func filterDataWith(text: String, and condition: Bool) {
//        isFiltered = condition
//        filteredCurrency = listOfCurrency.filter{ $0.lowercased().contains(text.lowercased()) }
//    }
    
//    private mutating func getCurrencies() {
//        let defaults = UserDefaults.standard
//        if (defaults.object(forKey: "currencies") != nil) {
//            listOfCurrency = UserDefaults.standard.object(forKey: "currencies") as? [String] ?? [String]()
//        } else {
//            NetworkManager.shared.fetchCurrencyList { result in
//                switch result {
//                case .success(let currencyList):
//                    listOfCurrency = currencyList.data.map{ $0.key }.sorted()
//                    defaults.set(listOfCurrency, forKey: "currencies")
//                case .failure(let error):
//                    networkErrorInBox.value = error
//                }
//            }
//        }
//    }
}

extension SelectCurrencyViewModel: ViewModelType {
    
    struct Inputs {
        let title: String
    }
    
    struct Bindings {}
    
    struct Dependencies {
        let networkService: NetworkManager
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
        let currencyInBox = Box<[String]>([])
        var cellViewModels = [CurrencyCellViewModel]()

        var listOfCurrency = [String]() {
            didSet {
                currencyInBox.value = listOfCurrency
                cellViewModels = createCellViewModels(for: listOfCurrency)
            }
        }
        
//        var isFiltered = false
//
//        var filteredCurrency = [String]() {
//            didSet {
//                currencyInBox.value = filteredCurrency
//            }
//        }
        
        func getCurrencies() {
            let defaults = UserDefaults.standard
            if (defaults.object(forKey: "currencies") != nil) {
                listOfCurrency = UserDefaults.standard.object(forKey: "currencies") as? [String] ?? [String]()
            } else {
                NetworkManager.shared.fetchCurrencyList { result in
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
        
        
        
//        func cellViewModel(forIndexPath indexPath: IndexPath) -> CurrencyCellViewModelType? {
//            let currency: String
//                currency = listOfCurrency[indexPath.row]
//            return CurrencyCellViewModel(currency: currency)
//        }
        let headerTitle = input
            .title
            .uppercased()
        
        return .init(headerTitle: headerTitle, networkErrorInBox: networkErrorInBox, currencyInBox: currencyInBox, listOfCurrency: listOfCurrency, cellViewModels: cellViewModels)
    }
}

