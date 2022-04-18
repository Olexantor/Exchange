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
    private let cellViewModels = BehaviorRelay<[CurrencyCellViewModel]>(value: [])
    
    private let didSelectCurrency = PublishRelay<CurrencyCellViewModel>()
    
    private let disposeBag = DisposeBag()
    
    private lazy var ui = createUI()
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
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
            searchText: ui.searchController.searchBar.rx.text.asDriver()
        )
    }
    
    func bind(to viewModel: ViewModel) {
        cellViewModels.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.ui.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.cellViewModels
            .drive(cellViewModels)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(ui.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.disposables
            .disposed(by: disposeBag)
    }
}
//MARK: - Setup UI

private extension SelectCurrencyViewController {
    struct UI {
        let tableView: UITableView
        let activityIndicator: UIActivityIndicatorView
        let searchController: UISearchController
    }
    
    func createUI() -> UI {
        title = "CURRENCIES"
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            CurrencyCell.self,
            forCellReuseIdentifier: CurrencyCell.identifier
        )
        tableView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.addSubview(tableView)
        
        let indicator =  UIActivityIndicatorView()
        indicator.style = .gray
        view.addSubview(indicator)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        searchController.searchBar.placeholder = "Search"
        self.navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        return .init(
            tableView: tableView,
            activityIndicator: indicator,
            searchController: searchController
        )
    }
    
    func layoutUI() {
        ui.tableView.pin.all()
        ui.activityIndicator.pin.center()
    }
}

