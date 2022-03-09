//
//  ViewController.swift
//  Exchange
//
//  Created by Александр on 08.03.2022.
//
import SnapKit
import UIKit

enum SelectButtonCondition {
    case firstButton, secondButton
}

class ExchangeViewController: UIViewController {
    
    var array = [String]()
    var dict = [String: Double]()
    
    private var viewModel: ExchangeViewModelType?
    
    private let exchangeImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "circleArrows")
        imageView.sizeToFit()
       return imageView
    }()
    
    private let fromCurrencyButton: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 1
        button.setTitle("select 1st currency", for: .normal)
        button.addTarget(self, action: #selector(selectCurrency), for: .touchUpInside)
        return button
        
    }()
    
    private let fromCurrencyTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "0.0"
        field.textAlignment  = .center
        return field
    }()
    
    private let fromCurrencyLabel: UILabel = {
        let label  = UILabel()
        label.text = ""
//        label.isEnabled = false
        return label
    }()
    
    private let intoCurrencyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("select 2nd currency", for: .normal)
        button.tag = 2
        button.addTarget(self, action: #selector(selectCurrency), for: .touchUpInside)
        return button
    }()
    
    private let intoCurrencyTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "0.0"
        field.textAlignment  = .center
        return field
    }()
    
    private let intoCurrencyLabel: UILabel = {
        let label  = UILabel()
        label.text = ""
        return label
     }()
    
    private let convertButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("convert", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        viewModel = ExchangeViewModel()
        title = "Exchange"
        addingSubviews()
        setupConstraints()
//        NetworkManager.shared.fetchCurrencyList { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let currencyList):
//                self.array = currencyList.data.map{ $0.key }
//                print(self.array)
//            case .failure(let error):
//                print(error)
//            }
//        }
//        NetworkManager.shared.fetchExchangeRate(with: "USD") { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let rate):
//                self.dict = rate.rates
//                print(self.dict)
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    func addingSubviews() {
        view.addSubview(exchangeImageView)
        view.addSubview(fromCurrencyButton)
        view.addSubview(fromCurrencyTextField)
        view.addSubview(fromCurrencyLabel)
        view.addSubview(intoCurrencyButton)
        view.addSubview(intoCurrencyTextField)
        view.addSubview(intoCurrencyLabel)
        view.addSubview(convertButton)
    }
    
    func setupConstraints() {
        exchangeImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
    
        fromCurrencyButton.snp.makeConstraints { make in
            make.top.equalTo(exchangeImageView.snp.bottom).offset(16)
            make.width.equalTo(170)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(fromCurrencyTextField.snp.top).offset(-24)
        }
        
        fromCurrencyTextField.snp.makeConstraints { make in
            make.width.equalTo(170)
            make.centerX.centerY.equalToSuperview()
        }
        
        fromCurrencyLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.bottom.equalTo(fromCurrencyTextField.snp.bottom)
            make.leading.equalTo(fromCurrencyTextField.snp.trailing)
            make.top.equalTo(fromCurrencyTextField.snp.top)
        }
        
        intoCurrencyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(fromCurrencyTextField.snp.width)
            make.top.equalTo(fromCurrencyTextField).offset(64)
        }
        
        intoCurrencyTextField.snp.makeConstraints { make in
            make.width.equalTo(fromCurrencyTextField.snp.width)
            make.centerX.equalToSuperview()
            make.top.equalTo(intoCurrencyButton.snp.bottom).offset(24)
        }
        
        intoCurrencyLabel.snp.makeConstraints { make in
            make.width.equalTo(fromCurrencyLabel.snp.width)
            make.bottom.equalTo(intoCurrencyTextField.snp.bottom)
            make.leading.equalTo(intoCurrencyTextField.snp.trailing)
            make.top.equalTo(intoCurrencyTextField.snp.top)
        }
        
        convertButton.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalTo(intoCurrencyTextField.snp.bottom).offset(64)
        }
    }
    
    @objc private func selectCurrency(sender: UIButton) {
//        let valutesTableViewController = ValutesTableViewController()
//        let
//        valutesTableViewController.delegate = self

        if sender.tag == 1 {
            let condition: SelectButtonCondition = .firstButton
            guard let currencyViewModel = viewModel?.viewModelWithSelected(condition: condition) else { return }
            navigationController?.pushViewController(SelectCurrencyViewController(viewModel: currencyViewModel), animated: true)
            print(1)
        } else {
            let condition: SelectButtonCondition = .secondButton
            guard let currencyViewModel = viewModel?.viewModelWithSelected(condition: condition) else { return }
            navigationController?.pushViewController(SelectCurrencyViewController(viewModel: currencyViewModel), animated: true)
            print(2)
        }
    }
    
    


}

