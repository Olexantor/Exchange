//
//  SelectCurrencyViewModelType.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

protocol SelectCurrencyViewModelType {
    var conditionOfButton: SelectButtonCondition { get }
    
    var networkError: Box<Error?> { get }
    
    var listOfCurrency: Box<[String]> { get }
    
    func getCurrencies()
    
    func numberOfRows() -> Int
    
    func cellViewModel(forIndexPath indexPath: IndexPath) -> CurrencyCellViewModelType?
}
