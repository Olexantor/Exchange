//
//  ViewController.swift
//  Exchange
//
//  Created by Александр on 08.03.2022.
//

import UIKit

class ViewController: UIViewController {
    
    var dict = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        title = "Exchange"
        NetworkManager.shared.fetchCurrencyList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let currencyList):
                self.dict = currencyList.currencies
                print(self.dict)
            case .failure(let error):
                print(error)
            }
        }
    }


}

