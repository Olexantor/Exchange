//
//  SelectCurrencyViewController.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//
import SnapKit
import UIKit

class SelectCurrencyViewController: UIViewController {
    
    private var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "currencyCell"
        )
        view.addSubview(tableView)
    }
    
    private func setupConstrains() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension SelectCurrencyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

extension SelectCurrencyViewController: UITableViewDelegate {
    
}
