import UIKit

/**
 Тут описаны протоколы для нашей архитектуры.
 Для реализации каждого экрана нужно подписываться под них.
 */

/// Технический протокол для обслуживания, напрямую его использовать не нужно, он не понадобится.
protocol HasEmptyInitialization {
    init()
}

/// Конструктор всех частей архитектуры в единую сущность.
protocol ScreenBuilder: HasEmptyInitialization {
    
    associatedtype VC: UIViewController & ViewType
    
    /// Здесь передаем все зависимости экрана.
    var dependencies: VC.ViewModel.Dependencies { get }
}

extension ScreenBuilder {
    
    /// Здесь создается контроллер, модель и роутер, и связываются друг с другом.
    func build(
        _ inputs: VC.ViewModel.Inputs
    ) -> VC where VC.ViewModel.Routes.TransitionHandler == UIViewController {
        
        let vc = VC.make()
        vc.loadViewIfNeeded()
        
        let vm = VC.ViewModel.configure(
            input: inputs,
            binding: vc.bindings,
            dependency: dependencies,
            router: VC.ViewModel.Routes(transitionHandler: vc)
        )
        
        vc.bind(to: vm)
        
        return vc
    }
}

/// Протокол, под который подписывается контроллер.
protocol ViewType: HasEmptyInitialization {
    
    associatedtype ViewModel: ViewModelType
    
    /// Здесь передаем все состояния и события из контроллера в модель.
    var bindings: ViewModel.Bindings { get }
    
    /// Здесь происходит привязка состояний модели к экрану.
    func bind(to viewModel: ViewModel)
    
    static func make() -> Self
}

extension ViewType {
    
    static func make() -> Self {
        return Self.init()
    }
}

/// Протокол, под который подписывается модель.
protocol ViewModelType {
    
    /// Содержит данные, приходящие извне, например, с предыдущего экрана.
    associatedtype Inputs = Void
    
    /// Содержит данные и события, приходящие из контроллера, например, нажатия на кнопки.
    associatedtype Bindings = Void
    
    /// Содержит зависимости, например, сетевой слой, хранилище и т.д.
    associatedtype Dependencies = Void
    
    /// Тип роутера, если экран никуда не ведет далее — то пустой.
    associatedtype Routes: RouterType = EmptyRouter
    
    /// Здесь происходит трансформация всех входных данных, и возвращается модель.
    static func configure(
        input: Inputs,
        binding: Bindings,
        dependency: Dependencies,
        router: Routes
    ) -> Self
}

/// Протокол, под который подписывается роутер.
protocol RouterType {
    
    associatedtype TransitionHandler
    
    init(transitionHandler: TransitionHandler)
}

/// Пустой роутер для экранов без навигации.
final class EmptyRouter: RouterType {
    required init(transitionHandler: UIViewController) {}
}
