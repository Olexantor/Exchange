//
//  CurrencyCell.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import UIKit

final class CurrencyCell: UITableViewCell {
    static let identifier = "currency cell"
    weak var viewModel: CurrencyCellViewModelType? {
        didSet {
            guard let viewModel = viewModel else { return }
            currencyLabel.text = viewModel.currency
        }
    }
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        addSubview(currencyLabel)
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupConstrains() {
        currencyLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}
