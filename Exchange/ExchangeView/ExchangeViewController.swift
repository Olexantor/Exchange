//
//  ViewController.swift
//  Exchange
//
//  Created by Александр on 08.03.2022.
//
import RxSwift
import RxCocoa
import SnapKit
import UIKit

final class ExchangeViewController: UIViewController {
    var disposeBag = DisposeBag()

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
        button.addTarget(
            self,
            action: #selector(selectCurrency),
            for: .touchUpInside
        )
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
        button.addTarget(
            self,
            action: #selector(selectCurrency),
            for: .touchUpInside
        )
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        setupNavigationBar()
        addingSubviews()
        setupConstraints()
        registerForKeyboardNotifications()
        hideKeyboardWhenTappedAround()
        firstCurrencyTextField.delegate = self
        secondCurrencyTextField.delegate =  self
//        UserDefaults.standard.removeObject(forKey: "currencies")
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
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
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.width.top.bottom.equalToSuperview()
        }
        
        exchangeImageView.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
        
        firstCurrencySelectionButton.snp.makeConstraints { make in
            make.width.equalTo(170)
            make.height.equalTo(32)
            make.centerX.equalToSuperview()
            make.top.equalTo(exchangeImageView.snp.bottom).offset(16)
        }
        
        firstCurrencyTextField.snp.makeConstraints { make in
            make.width.equalTo(170)
            make.height.equalTo(34)
            make.centerX.equalToSuperview()
            make.top.equalTo(firstCurrencySelectionButton.snp.bottom).offset(24)
        }
        
        firstCurrencyLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(32)
            make.centerY.equalTo(firstCurrencyTextField)
            make.leading.equalTo(firstCurrencyTextField.snp.trailing)
        }
        
        secondCurrencySelectionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(firstCurrencySelectionButton)
            make.width.equalTo(firstCurrencySelectionButton)
            make.top.equalTo(firstCurrencyTextField).offset(48)
        }
        
        secondCurrencyTextField.snp.makeConstraints { make in
            make.width.equalTo(firstCurrencyTextField.snp.width)
            make.height.equalTo(firstCurrencyTextField.snp.height)
            make.centerX.equalToSuperview()
            make.top.equalTo(secondCurrencySelectionButton.snp.bottom).offset(24)
            make.bottom.equalToSuperview().offset(-180)
        }
        
        secondCurrencyLabel.snp.makeConstraints { make in
            make.width.equalTo(firstCurrencyLabel.snp.width)
            make.height.equalTo(firstCurrencyLabel.snp.height)
            make.leading.equalTo(secondCurrencyTextField.snp.trailing)
            make.centerY.equalTo(secondCurrencyTextField)
        }
    }
    
    @objc private func selectCurrency(sender: UIButton) {
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
    
    //MARK: - Setup shifting content with NotificationCenter
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        )?.cgRectValue {
            var safeArea = self.view.frame
            safeArea.size.height += scrollView.contentOffset.y
            safeArea.size.height -= keyboardSize.height + (UIScreen.main.bounds.height*0.04)
            let activeField: UIView? = [
                firstCurrencyTextField,
                secondCurrencyTextField
            ].first { $0.isFirstResponder }
            if let activeField = activeField {
                if safeArea.contains(CGPoint(
                    x: 0,
                    y: activeField.frame.maxY
                )) {
                    return
                } else {
                    distance = activeField.frame.maxY - safeArea.size.height
                    scrollOffset = scrollView.contentOffset.y
                    self.scrollView.setContentOffset(
                        CGPoint(x: 0,y: scrollOffset + distance),
                        animated: true
                    )
                }
            }
            scrollView.isScrollEnabled = false
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if distance == 0 {
            return
        }
        self.scrollView.setContentOffset(
            CGPoint(x: 0, y: -scrollOffset - distance),
            animated: true
        )
        scrollOffset = 0
        distance = 0
        scrollView.isScrollEnabled = true
    }
    
    //MARK: - Keyboard Hiding Methods
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
//MARK: - Conform to ViewType

extension ExchangeViewController: ViewType {
    typealias ViewModel = ExchangeViewModel
    
    var bindings: ViewModel.Bindings {
        ViewModel.Bindings(
            didPressedFirstCurrenncyButton: firstCurrencySelectionButton.rx.tap.asSignal(),
            didPressedSecondCurrencyButton: secondCurrencySelectionButton.rx.tap.asSignal()
        )
    }
    
    func bind(to viewModel: ExchangeViewModel) {
        title = viewModel.headerTitle
        
        viewModel.firstCurrencyInBox.bind{ [weak self] currency in
            self?.firstCurrencyLabel.text = currency
        }
        
        viewModel.secondCurrencyInBox.bind{ [weak self] currency in
            self?.secondCurrencyLabel.text = currency
        }
        
        viewModel.disposables
            .disposed(by: disposeBag)
        
    }
}

//MARK: - UITextFieldDelegate

extension ExchangeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
    }
}







