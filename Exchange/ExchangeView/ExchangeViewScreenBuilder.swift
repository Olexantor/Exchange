//
//  ExchangeViewScreenBuilder.swift
//  Exchange
//
//  Created by Александр Николаев on 21.03.2022.
//

struct ExchangeViewScreenBuilder: ScreenBuilder {
    typealias VC = ExchangeViewController
    
    var dependencies: VC.ViewModel.Dependencies {
        .init(
            networkService: CurrencyService()
        )
    }
}
