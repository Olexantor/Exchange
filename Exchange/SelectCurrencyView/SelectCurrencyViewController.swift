//
//  SelectCurrencyViewController.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class SelectCurrencyViewController: UIViewController {
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let cellViewModels = BehaviorRelay<[CurrencyCellViewModel]>(value: [])
    
    private let didSelectCurrency = PublishRelay<CurrencyCellViewModel>()
    
    private let disposeBag = DisposeBag()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            CurrencyCell.self,
            forCellReuseIdentifier: CurrencyCell.identifier
        )
        tableView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.addSubview(tableView)
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .gray
        view.addSubview(indicator)
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CURRENCIES"
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.frame
        activityIndicator.center = view.center
    }
    
    private func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        searchController.searchBar.placeholder = "Search"
        self.navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}
//MARK: - UITableViewDataSource methods

extension SelectCurrencyViewController : UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        cellViewModels.value.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CurrencyCell.identifier,
            for: indexPath
        ) as? CurrencyCell
        
        guard let tableViewCell = cell else { return UITableViewCell() }
        tableViewCell.viewModel = cellViewModels.value[indexPath.row]
        return tableViewCell
    }
}
//MARK: - UITableViewDelegate

extension SelectCurrencyViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let cellViewModel = cellViewModels.value[indexPath.row]
        didSelectCurrency.accept(cellViewModel)
    }
}
//MARK: - Implement ViewType

extension SelectCurrencyViewController: ViewType {
    typealias ViewModel = SelectCurrencyViewModel
    
    var bindings: ViewModel.Bindings {
        .init(
            didSelectCurrency: didSelectCurrency.asSignal(),
            searchText: searchController.searchBar.rx.text.asDriver()
        )
    }
    
    func bind(to viewModel: ViewModel) {
        cellViewModels.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.cellViewModels
            .drive(cellViewModels)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.disposables
            .disposed(by: disposeBag)
    }
}
