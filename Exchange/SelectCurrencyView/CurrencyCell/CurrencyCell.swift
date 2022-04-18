//
//  CurrencyCell.swift
//  Exchange
//
//  Created by Александр on 09.03.2022.
//

import PinLayout
import UIKit

final class CurrencyCell: UITableViewCell {
    static let identifier = "currency cell"
    
    weak var viewModel: CurrencyCellViewModelType? {
        didSet {
            guard let viewModel = viewModel else { return }
            ui.currencyLabel.text = viewModel.currency
        }
    }
    
    private lazy var ui = createUI()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutUI()
    }
}

private extension CurrencyCell {
    
    struct UI {
        let currencyLabel: UILabel
    }
    
    func createUI() -> UI {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        contentView.addSubview(label)
        contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)

        return .init(currencyLabel: label)
    }
    
    func layoutUI() {
        ui.currencyLabel.pin.horizontally().vertically(8)
    }
}
