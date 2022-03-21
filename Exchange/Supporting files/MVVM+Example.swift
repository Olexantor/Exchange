import UIKit

/**
 Тут описан пример реализации архитектуры.
 */

/// Допустим, это наш `AppDelegate` и мы создаем начальный экран.
final class ApplicationDelegate {
    
    func makeWindow() -> UIWindow {
        /// Вот так создается любой экран, сюда передаются `Inputs` извне.
        let vc = ExampleScreenBuilder().build(.init(
            title: "Example"
        ))
        
        let window = UIWindow()
        window.rootViewController = vc
        return window
    }
}

/// Начинаем с реализации `ScreenBuilder`.
struct ExampleScreenBuilder: ScreenBuilder {
    
    typealias VC = ExampleViewController
    
    /// Здесь передаем все зависимости экрана, которые задаем в модели.
    var dependencies: VC.ViewModel.Dependencies {
        .init(
            networkService: NetworkService(),
            storageService: StorageService()
        )
    }
}

/// Далее делаем контроллер и подписываем под `ViewType`.
final class ExampleViewController: UIViewController, ViewType {
    
    typealias ViewModel = ExampleViewModel
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(
            self,
            action: #selector(buttonSelector),
            for: .touchUpInside
        )
        return button
    }()
    
    /// Здесь храним все состояния и события из экрана, которые хотим передать в модель.
    let bindings = ViewModel.Bindings()
    
    /// Здесь привязываем все состояния и события из модели к экрану.
    func bind(to viewModel: ExampleViewModel) {
        
        self.title = viewModel.headerTitle
    }
    
    @objc private func buttonSelector() {
        bindings.didTapButton()
    }
}

/// Далее делаем модель через `ViewModelType`.
struct ExampleViewModel: ViewModelType {
    
    /**
     Эти три структуры ниже задают входные данные.
    */
    
    struct Inputs {
        let title: String
    }
    
    final class Bindings {
        var didTapButton: () -> Void = {}
    }
    
    struct Dependencies {
        let networkService: NetworkService
        let storageService: StorageService
    }
    
    typealias Routes = ExampleRouter
    
    /// В модели с помощью свойств определяем выходные данные.
    let headerTitle: String
    
    /// Здесь все входящие потоки преобразуем в выходные данные.
    static func configure(
        input: Inputs,
        binding: Bindings,
        dependency: Dependencies,
        router: Routes
    ) -> ExampleViewModel {
        
        let headerTitle = input
            .title
            .uppercased()
        
        binding.didTapButton = {
            router.showAlert(title: input.title)
        }
        
        return .init(
            headerTitle: headerTitle
        )
    }
}

/// В конце — роутер через `RouterType`.
struct ExampleRouter: RouterType {
    
    let vc: UIViewController
    
    init(transitionHandler: UIViewController) {
        vc = transitionHandler
    }
    
    /// В роутере самостоятельно определяем необходимые методы навигации и создаем экраны.
    func showAlert(title: String) {
        
        let ac = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )
        
        vc.present(ac, animated: true)
    }
}

struct NetworkService {}
struct StorageService {}
