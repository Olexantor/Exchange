//
//  SelectCurrencyScreenBuilder.swift
//  Exchange
//
//  Created by Александр Николаев on 22.03.2022.
//

import UIKit

struct SelectCurrencyScreenBuilder: ScreenBuilder {
    typealias VC = SelectCurrencyViewController
    
    ///--- Перенеси каждую зависимость с новой строчки для читаемости.
    var dependencies: VC.ViewModel.Dependencies {
        .init(networkService: NetworkManager.shared, userDefaults: UserDefaults.standard)
    }
}
