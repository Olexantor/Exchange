//
//  SelectCurrencyViewController.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import SnapKit
import UIKit

final class SelectCurrencyViewController: UIViewController {

    private var tableView = UITableView()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var cellViewModels = [CurrencyCellViewModel]()
    
    let bindings = ViewModel.Bindings()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        indicator.hidesWhenStopped = true
        let transfrom = CGAffineTransform.init(scaleX: 3, y: 3)
        indicator.transform = transfrom
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        tableView.addSubview(activityIndicator)
        setupConstrains()
        setupSearchController()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        self.navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            CurrencyCell.self,
            forCellReuseIdentifier: CurrencyCell.identifier
        )
        view.addSubview(tableView)
    }
    
    private func setupConstrains() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    // MARK: - Alert
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Error!",
            message: "Something wrong with network",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
}
}
//MARK: - UITableViewDataSource methods

extension SelectCurrencyViewController : UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        cellViewModels.count
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
        tableViewCell.viewModel = cellViewModels[indexPath.row]
        return tableViewCell
    }
}
//MARK: - UITableViewDelegate

extension SelectCurrencyViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        bindings.didSelectCell(indexPath)
    }
}
//MARK: - Implement ViewType

extension SelectCurrencyViewController: ViewType {
    typealias ViewModel = SelectCurrencyViewModel
    
    func bind(to viewModel: ViewModel) {
        title = viewModel.headerTitle
        
        viewModel.cellViewModels.bind { [weak self] cellsModels in
            self?.cellViewModels = cellsModels
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.isIndicatorEnabled.bind{ [weak self] condition in
            if condition {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.networkErrorInBox.bind { [weak self] error in
            guard let self = self else { return }
            guard error != nil else { return }
            self.showAlert()
        }
    }
}
//MARK: - SearchResultsUpdating

extension SelectCurrencyViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    private func filterContentForSearchedText(_ searchText: String) {
    }
}

