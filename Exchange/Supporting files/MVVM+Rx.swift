//
//  MVVM+Rx.swift
//  Exchange
//
//  Created by Nikolay Davydov on 08.04.2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

struct User: Codable {
    let name: String
    let email: String
}

struct UsersService {
    
    func fetchUsers() -> Single<[User]> {
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let request = URLRequest(url: url)
        
        return URLSession.shared.rx
            .data(request: request)
            .map { try JSONDecoder().decode([User].self, from: $0) }
            .asSingle()
    }
}

struct UsersScreenBuilder: ScreenBuilder {
    
    typealias VC = UsersViewController
    
    var dependencies: VC.ViewModel.Dependencies {
        .init(
            usersService: UsersService()
        )
    }
}

final class UsersViewController: UIViewController {
    
    private let users = BehaviorRelay<[User]>(value: [])
    private let didSelectUser = PublishRelay<User>()
    
    private let disposeBag = DisposeBag()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellID)
        view.addSubview(tv)
        return tv
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.style = .gray
        view.addSubview(ai)
        return ai
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.frame
        activityIndicator.center = view.center
    }
}

extension UsersViewController: ViewType {
    
    typealias ViewModel = UsersViewModel
    
    var bindings: UsersViewModel.Bindings {
        .init(
            didSelectUser: didSelectUser.asSignal()
        )
    }
    
    func bind(to viewModel: UsersViewModel) {
        
        users.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.users
            .drive(users)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.disposables
            .disposed(by: disposeBag)
    }
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    private static let cellID = "cellID"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID)
        let user = users.value[indexPath.row]
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.email
        return cell ?? .init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users.value[indexPath.row]
        didSelectUser.accept(user)
    }
}

struct UsersViewModel {
    
    let users: Driver<[User]>
    let isLoading: Driver<Bool>
    let disposables: Disposable
}

extension UsersViewModel: ViewModelType {
    
    struct Inputs {}
    
    struct Bindings {
        let didSelectUser: Signal<User>
    }
    
    struct Dependencies {
        let usersService: UsersService
    }
    
    typealias Routes = UsersRouter
    
    static func configure(
        input: Inputs,
        binding: Bindings,
        dependency: Dependencies,
        router: Routes
    ) -> UsersViewModel {
        
        let users = BehaviorRelay<[User]>(value: [])
        let didReceiveError = PublishRelay<String>()
        
        let fetchUsers = dependency
            .usersService
            .fetchUsers()
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .asSignal { error in
                didReceiveError.accept(error.localizedDescription)
                return .just([])
            }
            .emit(to: users)
        
        let isLoading = users
            .asDriver()
            .map { $0.isEmpty }
        
        let showError = didReceiveError
            .asSignal()
            .emit(onNext: { error in
                router.showAlert(title: error)
            })
        
        let showUser = binding
            .didSelectUser
            .emit(onNext: { user in
                router.showAlert(title: user.name)
            })
        
        let disposables = CompositeDisposable(
            fetchUsers,
            showError,
            showUser
        )
        
        return .init(
            users: users.asDriver(),
            isLoading: isLoading,
            disposables: disposables
        )
    }
}

struct UsersRouter: RouterType {
    
    let vc: UIViewController
    
    init(transitionHandler: UIViewController) {
        vc = transitionHandler
    }
    
    func showAlert(title: String) {
        
        let ac = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )
        
        ac.addAction(.init(title: "OK", style: .default))
        
        vc.present(ac, animated: true)
    }
}

