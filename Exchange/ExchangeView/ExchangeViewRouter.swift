//
//  ExchangeViewRouter.swift
//  Exchange
//
//  Created by Александр Николаев on 21.03.2022.
//

import UIKit

struct ExchangeViewRouter: RouterType {
    let vc: UIViewController
    
    init(transitionHandler: UIViewController) {
        vc = transitionHandler
    }
    
    func showSelectCurrencyView(with completion: @escaping (String) -> Void) {
        let newVC = SelectCurrencyScreenBuilder().build(.init(didSelectCurrency: completion))
        vc.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func showAlert(with message: String) {
        let alert = UIAlertController(
            title: "Error!",
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        vc.present(alert, animated: true)
    }
}
