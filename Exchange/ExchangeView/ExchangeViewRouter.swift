//
//  ExchangeViewRouter.swift
//  Exchange
//
//  Created by Александр Николаев on 21.03.2022.
//

import Foundation
import UIKit

struct ExchangeViewRouter: RouterType {
    let vc: UIViewController
    
    init(transitionHandler: UIViewController) {
        vc = transitionHandler
    }
    
    func showSelectCurrencyView(with title: String, and completion: @escaping (String) -> Void) {
        let newVC = SelectCurrencyScreenBuilder().build(.init(title: title, onCompletion: completion))
        vc.navigationController?.pushViewController(newVC, animated: true)
    }
}
