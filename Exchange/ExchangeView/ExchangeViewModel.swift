//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//
import RxCocoa
import RxSwift

import Foundation

struct ExchangeViewModel {
    let headerTitle: String
    let disposables: Disposable
    let firstCurrencyInBox: Box<String>
    let secondCurrencyInBox: Box<String>
}

extension ExchangeViewModel: ViewModelType {
 
    struct Inputs{
        let title: String
    }
    
    struct Bindings {
        let didPressedFirstCurrenncyButton: Signal<Void>
        let didPressedSecondCurrencyButton: Signal<Void>
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
        
        let headerTitle = input
            .title
            .uppercased()
        
        let firstCurrencyNameInBox = Box<String>("")
        let secondCurrencyNameInBox = Box<String>("")
        
        let firstButtonDisposable = binding.didPressedFirstCurrenncyButton.debug("====")
            .emit(onNext: { _ in
                router.showSelectCurrencyView(with: "currencies") {
                    firstCurrencyNameInBox.value = $0
                }
            })
        
        let secondButtonDisposable = binding.didPressedSecondCurrencyButton.debug("====")
            .emit(onNext: { _ in
                router.showSelectCurrencyView(with: "currencies") {
                    firstCurrencyNameInBox.value = $0
                }
            })
        
        return .init(
            headerTitle: headerTitle,
            disposables: CompositeDisposable(firstButtonDisposable, secondButtonDisposable),
            firstCurrencyInBox: firstCurrencyNameInBox,
            secondCurrencyInBox: secondCurrencyNameInBox
        )
    }
}
