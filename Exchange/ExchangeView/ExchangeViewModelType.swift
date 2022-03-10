//
//  ExchangeViewModelType.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

protocol ExchangeViewModelType {
    
    var fromCurrencyName: Box<String>  { get }
    
    var intoCurrencyName: Box<String> { get }
    
    var fromCurrencyValue: Double { get }
    
    var intoCurrencyValue: Double { get }
    
    func viewModelWithSelected(condition: SelectButtonCondition) -> SelectCurrencyViewModelType?
}
