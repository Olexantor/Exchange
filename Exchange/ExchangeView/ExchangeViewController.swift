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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var scrollOffset : CGFloat = 0
    private var distance : CGFloat = 0
    
    private var exchViewModel: ExchangeViewModelType?
    
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
        field.keyboardType = .decimalPad
        return field
    }()
    
    private let fromCurrencyLabel: UILabel = {
        let label  = UILabel()
        label.text = ""
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
        field.keyboardType = .decimalPad
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
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        exchViewModel = ExchangeViewModel()
        title = "Exchange"
        addingSubviews()
        setupConstraints()
        setupBindings()
        registerForKeyboardNotifications()
        hideKeyboardWhenTappedAround()
        //        NetworkManager.shared.fetchCurrencyList { [weak self] result in
        //            guard let self = self else { return }
        //            switch result {
        //            case .success(let currencyList):
        //                self.array = currencyList.data.map{ $0.key }.sorted()
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
    
    deinit {
        removeKeyboardNotifications()
    }
    
    private func addingSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(exchangeImageView)
        contentView.addSubview(fromCurrencyButton)
        contentView.addSubview(fromCurrencyTextField)
        contentView.addSubview(fromCurrencyLabel)
        contentView.addSubview(intoCurrencyButton)
        contentView.addSubview(intoCurrencyTextField)
        contentView.addSubview(intoCurrencyLabel)
        contentView.addSubview(convertButton)
    }
    
    private func setupConstraints() {
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.width.top.bottom.equalToSuperview()
        }
        
        exchangeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
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
            make.top.equalTo(intoCurrencyTextField.snp.bottom).offset(32)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupBindings() {
        exchViewModel?.fromCurrencyName.bind { [weak self] currency in
            self?.fromCurrencyLabel.text = currency
        }
        exchViewModel?.intoCurrencyName.bind { [weak self] currency in
            self?.intoCurrencyLabel.text = currency
        }
    }
    
    @objc private func selectCurrency(sender: UIButton) {
        let condition: SelectButtonCondition = sender.tag == 1 ? .firstButton : .secondButton
        guard var currencyViewModel = exchViewModel?.viewModelWithSelected(condition: condition) else { return }
        let selectCurrencyVC = SelectCurrencyViewController(viewModel: currencyViewModel)
        currencyViewModel.delegate = exchViewModel as? SelectedCurrencyDelegate
        navigationController?.pushViewController(selectCurrencyVC, animated: true)
    }
    
    //MARK: - Setup shifting content with NotificationCenter
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            var safeArea = self.view.frame
            safeArea.size.height += scrollView.contentOffset.y
            safeArea.size.height -= keyboardSize.height + (UIScreen.main.bounds.height*0.04) // Adjust buffer to your liking
            
            let activeField: UIView? = [fromCurrencyTextField, intoCurrencyTextField].first { $0.isFirstResponder }
            if let activeField = activeField {
                if safeArea.contains(CGPoint(x: 0, y: activeField.frame.maxY)) {
                    print("No need to Scroll")
                    return
                } else {
                    distance = activeField.frame.maxY - safeArea.size.height
                    scrollOffset = scrollView.contentOffset.y
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset + distance), animated: true)
                    
                }
            }
            scrollView.isScrollEnabled = false
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if distance == 0 {
            return
        }
        self.scrollView.setContentOffset(CGPoint(x: 0, y: -scrollOffset), animated: true)
        scrollOffset = 0
        distance = 0
        scrollView.isScrollEnabled = true
    }
    //MARK: - Keyboard Hiding Methods
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
//MARK: - UITextFieldDelegate
extension ExchangeViewController: UITextFieldDelegate {
    
}






