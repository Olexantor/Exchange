//
//  SelectCurrencyViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

struct SelectCurrencyViewModel {
//    :SelectCurrencyViewModelType

    let headerTitle: String

    let networkErrorInBox: Box<Error?>
    
    let cellViewModels:Box<[CurrencyCellViewModel]>
    
//    var currencyInBox: Box<[String]>
//    
//    var listOfCurrency: [String]
    
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
    
//    func cellViewModel(forIndexPath indexPath: IndexPath) -> CurrencyCellViewModelType? {
//        let currency: String
//        if isFiltered {
//            currency = filteredCurrency[indexPath.row]
//        } else {
//            currency = listOfCurrency[indexPath.row]
//        }
//        return CurrencyCellViewModel(currency: currency)
//    }
    
//    func createCellViewModels(for currencies: [String]) -> [CurrencyCellViewModel] {
//        var cellViewModels = [CurrencyCellViewModel]()
//        currencies.forEach { currency in
//            cellViewModels.append(CurrencyCellViewModel(currency: currency))
//        }
//        return cellViewModels
//    }
    
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
        //        let currencyInBox = Box<[String]>([])
        //                currencyInBox.value = listOfCurrency
        
        //        var isFiltered = false
        //
        //        var filteredCurrency = [String]() {
        //            didSet {
        //                currencyInBox.value = filteredCurrency
        //            }
        //        }
        func createCellViewModels(for currencies: [String]) -> [CurrencyCellViewModel] {
            var cellViewModels = [CurrencyCellViewModel]()
            currencies.forEach { currency in
                cellViewModels.append(CurrencyCellViewModel(currency: currency))
            }
            return cellViewModels
        }
        
        let networkErrorInBox = Box<Error?>(nil)
        let cellViewModels = Box<[CurrencyCellViewModel]>([])

        var listOfCurrency = [String]() {
            didSet {
                cellViewModels.value = createCellViewModels(for: listOfCurrency)
            }
        }
        
        
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
        
        let headerTitle = input
            .title
            .uppercased()
        
        return .init(
            headerTitle: headerTitle,
            networkErrorInBox: networkErrorInBox,
            cellViewModels: cellViewModels
        )
    }
}

