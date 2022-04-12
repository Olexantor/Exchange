//
//  SelectCurrencyRouter.swift
//  Exchange
//
//  Created by Александр Николаев on 22.03.2022.
//

import UIKit

struct SelectCurrencyRouter: RouterType {
    let vc: UIViewController
    
    init(transitionHandler: UIViewController) {
        vc = transitionHandler
    }
    
    func popViewController() {
        vc.navigationController?.popViewController(animated: true)
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

