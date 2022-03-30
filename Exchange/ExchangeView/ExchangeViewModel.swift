//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

struct ExchangeViewModel {
    let firstCurrencyInBox: Box<String>
    let secondCurrencyInBox: Box<String>
}

extension ExchangeViewModel: ViewModelType {
    final class Bindings {
        var didPressedSelectCurrenncyButton: (ButtonNumberInOrder) -> Void = {_ in}
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
        
        binding.didPressedSelectCurrenncyButton = { buttonNumber in
            switch buttonNumber {
            case .first:
                router.showSelectCurrencyView {
                    firstCurrencyNameInBox.value = $0
                }
            case .second:
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
