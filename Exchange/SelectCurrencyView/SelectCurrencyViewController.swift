//
//  SelectCurrencyViewController.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//
import SnapKit
import UIKit
import SwiftUI

class SelectCurrencyViewController: UIViewController {
    
    weak var delegate: SelectedCurrencyDelegate?
    
    private let selectViewModel: SelectCurrencyViewModelType
    
    private var tableView = UITableView()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        indicator.hidesWhenStopped = true
        let transfrom = CGAffineTransform.init(scaleX: 3, y: 3)
        indicator.transform = transfrom
        return indicator
    }()

    init(viewModel: SelectCurrencyViewModelType) {
        self.selectViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        setupTableView()
        setupConstrains()
        setupBindings()
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
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        selectViewModel.currencyInBox.bind { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
        selectViewModel.networkErrorInBox.bind { [weak self] error in
            guard let self = self else { return }
            guard error != nil else { return }
            self.showAlert()
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

extension SelectCurrencyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectViewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.identifier, for: indexPath) as? CurrencyCell
        guard let tableViewCell = cell else { return UITableViewCell() }
        let cellViewModel = selectViewModel.cellViewModel(forIndexPath: indexPath)
        tableViewCell.viewModel = cellViewModel
        return tableViewCell
    }
}
//MARK: - UITableViewDelegate

extension SelectCurrencyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectViewModel.delegate?.selectedCurrencyWith(currencyName: selectViewModel.currencyInBox.value[indexPath.row], and: selectViewModel.conditionOfButton)
        navigationController?.popViewController(animated: true)
    }
}

