//
//  ExchangeViewModelType.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import Foundation

protocol ExchangeViewModelType {
    func viewModelWithSelected(condition: SelectButtonCondition) -> SelectCurrencyViewModelType?
}
