//
//  ExchangeViewRouter.swift
//  Exchange
//
//  Created by Александр Николаев on 21.03.2022.
//

import UIKit
import RxSwift
import RxCocoa

struct ExchangeViewRouter: RouterType {
    let vc: UIViewController
    
    init(transitionHandler: UIViewController) {
        vc = transitionHandler
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
    
    func showSelectCurrencyViewController() -> Signal<String> {
        Observable<String>.create { observer in
            showSelectCurrencyView { currency in
                observer.onNext(currency)
            }
            return Disposables.create()
        }
        .asSignal(onErrorJustReturn: "")
    }
    
    private func showSelectCurrencyView(with completion: @escaping (String) -> Void) {
        let newVC = SelectCurrencyScreenBuilder().build(.init(didSelectCurrency: completion))
        vc.navigationController?.pushViewController(newVC, animated: true)
    }
    
}
