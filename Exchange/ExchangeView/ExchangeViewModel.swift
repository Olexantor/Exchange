//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//
import RxCocoa
import RxSwift

import Foundation
import UIKit

struct ExchangeViewModel {
    let firstCurrencyInBox: Box<String>
    let secondCurrencyInBox: Box<String>
}

extension ExchangeViewModel: ViewModelType {
    
    struct Inputs{
    }
    
    final class Bindings {
        var didPressedSelectCurrenncyButton: (UIButton) -> Void = {_ in}
    }
    
    struct Dependencies {
        let networkService: NetworkManager
    }
    
    typealias Routes = ExchangeViewRouter
    
    static func configure(
        input: Inputs,
        binding: Bindings,
        dependency: Dependencies,
        router: Routes
    ) -> Self {
        
        let firstCurrencyNameInBox = Box<String>("")
        let secondCurrencyNameInBox = Box<String>("")
        
        
        binding.didPressedSelectCurrenncyButton = { button in
            if button.tag == 1 {
                router.showSelectCurrencyView {
                    firstCurrencyNameInBox.value = $0
                }
            } else {
                router.showSelectCurrencyView {
                    secondCurrencyNameInBox.value = $0
                }
            }
        }
        
        return .init(
            firstCurrencyInBox: firstCurrencyNameInBox,
            secondCurrencyInBox: secondCurrencyNameInBox
        )
    }
}
