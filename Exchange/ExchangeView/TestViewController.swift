//
//  TestViewController.swift
//  Exchange
//
//  Created by Александр Николаев on 21.03.2022.
//

import UIKit

struct TestScreenBuilder: ScreenBuilder {
    var dependencies: TestViewModel.Dependencies {.init(networkService: NetworkManager.shared)
        
    }
    
    
    typealias VC = TestViewController
    
}

class TestViewController: UIViewController, ViewType {
    var bindings = ViewModel.Bindings()
    
    func bind(to viewModel: TestViewModel) {
    
    }
    
    typealias ViewModel = TestViewModel
    
    
}

struct TestViewModel: ViewModelType {
    
    struct Dependencies {
        let networkService: NetworkManager
    }
    
    struct Inputs {
        let message: String
    }
    
    static func configure(
        input: Inputs,
        binding: (),
        dependency: Dependencies,
        router: EmptyRouter
    ) -> TestViewModel {
        
        input.message
        dependency.networkService
        return TestViewModel()
    }
    
    
}
