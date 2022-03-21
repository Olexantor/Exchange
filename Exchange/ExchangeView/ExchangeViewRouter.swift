//
//  ExchangeViewRouter.swift
//  Exchange
//
//  Created by Александр Николаев on 21.03.2022.
//

import Foundation
import UIKit

struct ExchangeViewRouter: RouterType {
    let vc: ExchangeViewController
    
    init(transitionHandler: ExchangeViewController) {
        vc = transitionHandler
    }
}
