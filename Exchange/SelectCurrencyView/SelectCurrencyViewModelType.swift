//
//  SelectCurrencyViewModelType.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

protocol SelectCurrencyViewModelType {
    var conditionOfButton: SelectButtonCondition { get }
    
    var networkErrorInBox: Box<Error?> { get }
    
    var currencyInBox: Box<[String]> { get }
    
    func numberOfRows() -> Int
    
    func cellViewModel(forIndexPath indexPath: IndexPath) -> CurrencyCellViewModelType?
}
