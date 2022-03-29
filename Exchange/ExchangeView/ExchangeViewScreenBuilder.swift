//
//  ExchangeViewScreenBuilder.swift
//  Exchange
//
//  Created by Александр Николаев on 21.03.2022.
//

import UIKit

struct ExchangeScreenBuilder: ScreenBuilder {
    
    
    typealias VC = ExchangeViewController
    
    var dependencies: ExchangeViewController.ViewModel.Dependencies {
        .init(networkService: NetworkManager.shared)
    }
}
