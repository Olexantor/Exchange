//
//  ExchangeViewModelType.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation
import UIKit

protocol ExchangeViewModelType {
    var firstCurrencyNameInBox: Box<String>  { get }
    
    var secondCurrencyNameInBox: Box<String> { get }

    var firstCurrencyCalculatedValueInBox: Box<String> { get }
    
    var secondCurrencyCalculatedValueInBox: Box<String> { get }
    
    var networkErrorInBox: Box<Error?> { get }
    
    var saveLocation: SaveLocation? { get set }
    
    var ratesForFirstCurrency: [String: Double] { get }
    
    var ratesForSecondCurrency: [String: Double] { get }
    
    func viewModelWithSelected(condition: SelectButtonCondition) -> SelectCurrencyViewModelType?
    
    func clearingTheFieldFor(textFieldID: TextFieldID)
    
    func getCurrencyRates(for currency: String, with saveLocation: SaveLocation?)
    
    func calculateValueFor(for value: String, from textField: TextFieldID)
}
