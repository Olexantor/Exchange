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
    
    func showAlert() {
        let alert = UIAlertController(
            title: "Error!",
            message: "Something wrong with network",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        vc.present(alert, animated: true)
    }
}

