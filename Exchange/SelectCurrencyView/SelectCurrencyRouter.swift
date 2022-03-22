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
}
