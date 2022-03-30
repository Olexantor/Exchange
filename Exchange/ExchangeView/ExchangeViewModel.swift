//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

struct ExchangeViewModel {
    let firstCurrencyInBox: Box<String>
    let secondCurrencyInBox: Box<String>
    let firstCurrencyCalculatedValueInBox: Box<String>
    let secondCurrencyCalculatedValueInBox: Box<String>
}

extension ExchangeViewModel: ViewModelType {
    final class Bindings {
        var didPressedSelectCurrenncyButton: (ButtonNumberInOrder) -> Void = {_ in}
        var didTapOnTextField: (TextFieldID) -> Void = {_ in }
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
        let firstCurrencyCalculatedValue = Box<String>("")
        let secondCurrencyCalculatedValue =  Box<String>("")
        
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
        
        binding.didTapOnTextField = { textFieldID in
            switch textFieldID {
            case .firstTF:
                secondCurrencyCalculatedValue.value = ""
            case .secondTF:
                firstCurrencyCalculatedValue.value = ""
            }
        }
        
        return .init(
            firstCurrencyInBox: firstCurrencyNameInBox,
            secondCurrencyInBox: secondCurrencyNameInBox,
            firstCurrencyCalculatedValueInBox: firstCurrencyCalculatedValue,
            secondCurrencyCalculatedValueInBox: secondCurrencyCalculatedValue
        )
    }
}
