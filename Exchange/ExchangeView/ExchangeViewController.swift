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

enum TextFieldID {
    case firstTF, secondTF
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
    
    private let firstCurrencySelectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tag = 1
        button.setTitle("select 1st currency", for: .normal)
        button.addTarget(self, action: #selector(selectCurrency), for: .touchUpInside)
        return button
        
    }()
    
    private let firstCurrencyTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "0.0"
        field.textAlignment  = .center
        field.keyboardType = .decimalPad
        return field
    }()
    
    private var firstCurrencyLabel: UILabel = {
        let label  = UILabel()
        label.text = ""
        return label
    }()
    
    private let secondCurrencySelectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("select 2nd currency", for: .normal)
        button.tag = 2
        button.addTarget(self, action: #selector(selectCurrency), for: .touchUpInside)
        return button
    }()
    
    private let secondCurrencyTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "0.0"
        field.textAlignment  = .center
        field.keyboardType = .decimalPad
        return field
    }()
    
    private var secondCurrencyLabel: UILabel = {
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
        firstCurrencyTextField.delegate = self
        secondCurrencyTextField.delegate =  self
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    private func addingSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(exchangeImageView)
        contentView.addSubview(firstCurrencySelectionButton)
        contentView.addSubview(firstCurrencyTextField)
        contentView.addSubview(firstCurrencyLabel)
        contentView.addSubview(secondCurrencySelectionButton)
        contentView.addSubview(secondCurrencyTextField)
        contentView.addSubview(secondCurrencyLabel)
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
        
        firstCurrencySelectionButton.snp.makeConstraints { make in
            make.top.equalTo(exchangeImageView.snp.bottom).offset(16)
            make.width.equalTo(170)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(firstCurrencyTextField.snp.top).offset(-24)
        }
        
        firstCurrencyTextField.snp.makeConstraints { make in
            make.width.equalTo(170)
            make.centerX.centerY.equalToSuperview()
        }
        
        firstCurrencyLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.bottom.equalTo(firstCurrencyTextField.snp.bottom)
            make.leading.equalTo(firstCurrencyTextField.snp.trailing)
            make.top.equalTo(firstCurrencyTextField.snp.top)
        }
        
        secondCurrencySelectionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(firstCurrencyTextField.snp.width)
            make.top.equalTo(firstCurrencyTextField).offset(64)
        }
        
        secondCurrencyTextField.snp.makeConstraints { make in
            make.width.equalTo(firstCurrencyTextField.snp.width)
            make.centerX.equalToSuperview()
            make.top.equalTo(secondCurrencySelectionButton.snp.bottom).offset(24)
        }
        
        secondCurrencyLabel.snp.makeConstraints { make in
            make.width.equalTo(firstCurrencyLabel.snp.width)
            make.bottom.equalTo(secondCurrencyTextField.snp.bottom)
            make.leading.equalTo(secondCurrencyTextField.snp.trailing)
            make.top.equalTo(secondCurrencyTextField.snp.top)
        }
        
        convertButton.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalTo(secondCurrencyTextField.snp.bottom).offset(32)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupBindings() {
        exchViewModel?.firstCurrencyNameInBox.bind { [weak self] currency in
            self?.firstCurrencyLabel.text = currency
            self?.exchViewModel?.saveLocation = .firstDictionary
            self?.exchViewModel?.getCurrencyRates(for: currency, with: self?.exchViewModel?.saveLocation)
        }
        exchViewModel?.secondCurrencyNameInBox.bind { [weak self] currency in
            self?.secondCurrencyLabel.text = currency
            self?.exchViewModel?.saveLocation = .secondDictionary
            self?.exchViewModel?.getCurrencyRates(for: currency, with: self?.exchViewModel?.saveLocation)
        }
        
        exchViewModel?.firstCurrencyCalculatedValueInBox.bind{ [weak self] currencyValue in
            self?.firstCurrencyTextField.text = currencyValue
        }
        
        exchViewModel?.secondCurrencyCalculatedValueInBox.bind{ [weak self] currencyValue in
            self?.secondCurrencyTextField.text = currencyValue
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
            
            let activeField: UIView? = [firstCurrencyTextField, secondCurrencyTextField].first { $0.isFirstResponder }
            if let activeField = activeField {
                if safeArea.contains(CGPoint(x: 0, y: activeField.frame.maxY)) {
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
        self.scrollView.setContentOffset(CGPoint(x: 0, y: -scrollOffset - distance), animated: true)
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let textFieldID: TextFieldID = textField == firstCurrencyTextField ? .firstTF : .secondTF
        exchViewModel?.clearingTheFieldFor(textFieldID: textFieldID)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let textFieldID: TextFieldID = textField == firstCurrencyTextField ? .firstTF : .secondTF
        guard let value = textField.text else { return}
        exchViewModel?.calculateValueFor(for: value, from: textFieldID)
    }
    
}






