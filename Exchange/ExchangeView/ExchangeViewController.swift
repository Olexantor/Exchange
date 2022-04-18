//
//  ViewController.swift
//  Exchange
//
//  Created by Александр on 08.03.2022.
//
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class ExchangeViewController: UIViewController {
    private lazy var ui = createUI()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
    
    deinit {
        removeKeyboardNotifications()
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
            safeArea.size.height += ui.scrollView.contentOffset.y
            safeArea.size.height -= keyboardSize.height + (UIScreen.main.bounds.height*0.04)
            let activeField: UIView? = [
                ui.firstCurrencyTextField,
                ui.secondCurrencyTextField
            ].first { $0.isFirstResponder }
            if let activeField = activeField {
                if safeArea.contains(CGPoint(
                    x: 0,
                    y: activeField.frame.maxY
                )) {
                    return
                } else {
                    Variables.distance = activeField.frame.maxY - safeArea.size.height
                    Variables.scrollOffset = ui.scrollView.contentOffset.y
                    self.ui.scrollView.setContentOffset(
                        CGPoint(x: 0,y: Variables.scrollOffset + Variables.distance),
                        animated: true
                    )
                }
            }
            ui.scrollView.isScrollEnabled = false
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if Variables.distance == 0 {
            return
        }
        self.ui.scrollView.setContentOffset(
            CGPoint(x: 0, y: -Variables.scrollOffset - Variables.distance),
            animated: true
        )
        Variables.scrollOffset = 0
        Variables.distance = 0
        ui.scrollView.isScrollEnabled = true
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
        .init(
            didTapFirstCurrencySelectionButton: ui.firstCurrencySelectionButton.rx.tap.asSignal(),
            didTapSecondCurrencySelectionButton: ui.secondCurrencySelectionButton.rx.tap.asSignal(),
            textOfFirstCurrencyTextField: ui.firstCurrencyTextField.rx.text.asDriver(),
            textOfSecondCurrencyTextField: ui.secondCurrencyTextField.rx.text.asDriver()
        )
    }
    
    func bind(to viewModel: ExchangeViewModel) {
        viewModel.firstCurrency
            .drive(ui.firstCurrencyLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.secondCurrency
            .drive(ui.secondCurrencyLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.firstCurrencyCalculatedValue
            .drive(ui.firstCurrencyTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.secondCurrencyCalculatedValue
            .drive(ui.secondCurrencyTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.disposables
            .disposed(by: disposeBag)
    }
}
//MARK:  - Setup UI

private extension ExchangeViewController {
    enum Variables {
        static var scrollOffset : CGFloat = 0
        static var distance : CGFloat = 0
    }
    
    struct UI {
        let scrollView: UIScrollView
        let contentView: UIView
        let exchangeImageView: UIImageView
        let firstCurrencySelectionButton: UIButton
        let firstCurrencyTextField: UITextField
        let firstCurrencyLabel: UILabel
        let secondCurrencySelectionButton: UIButton
        let secondCurrencyTextField: UITextField
        let secondCurrencyLabel: UILabel
    }
    
    func createUI() -> UI {
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        title = "EXCHANGE"
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "circleArrows")
        contentView.addSubview(imageView)
        
        let firstButton = UIButton(type: .system)
        firstButton.setTitle("select 1st currency", for: .normal)
        contentView.addSubview(firstButton)
        
        let firstTF = UITextField()
        firstTF.placeholder = "0.0"
        firstTF.textAlignment  = .center
        firstTF.keyboardType = .decimalPad
        contentView.addSubview(firstTF)

        let firstLabel  = UILabel()
        firstLabel.text = ""
        contentView.addSubview(firstLabel)

        let secondButton = UIButton(type: .system)
        secondButton.setTitle("select 2nd currency", for: .normal)
        contentView.addSubview(secondButton)
    
        let secondTF = UITextField()
        secondTF.placeholder = "0.0"
        secondTF.textAlignment  = .center
        secondTF.keyboardType = .decimalPad
        contentView.addSubview(secondTF)
      
        let secondLabel  = UILabel()
        secondLabel.text = ""
        contentView.addSubview(secondLabel)
        
        
        return .init(
            scrollView: scrollView,
            contentView: contentView,
            exchangeImageView: imageView,
            firstCurrencySelectionButton: firstButton,
            firstCurrencyTextField: firstTF,
            firstCurrencyLabel: firstLabel,
            secondCurrencySelectionButton: secondButton,
            secondCurrencyTextField: secondTF,
            secondCurrencyLabel:secondLabel
        )
    }
    
    func layoutUI() {
        ui.scrollView.pin.all()
        
        ui.contentView.pin
            .width(of: ui.scrollView)
            .vertically()
        
        ui.exchangeImageView.pin
            .size(100)
            .hCenter()
            .top(50)
        
        ui.firstCurrencySelectionButton.pin
            .width(170)
            .height(32)
            .hCenter()
            .top(to: ui.exchangeImageView.edge.bottom).marginTop(16)

        ui.firstCurrencyTextField.pin
            .width(of: ui.firstCurrencySelectionButton)
            .height(34)
            .hCenter().top(to: ui.firstCurrencySelectionButton.edge.bottom).marginTop(24)

        ui.firstCurrencyLabel.pin
            .width(40)
            .height(32)
            .vCenter(to: ui.firstCurrencyTextField.edge.vCenter)
            .left(to: ui.firstCurrencyTextField.edge.right)

        ui.secondCurrencySelectionButton.pin
            .hCenter()
            .size(of: ui.firstCurrencySelectionButton)
            .top(to: ui.firstCurrencyTextField.edge.bottom).marginTop(48)

        ui.secondCurrencyTextField.pin
            .hCenter()
            .size(of: ui.firstCurrencyTextField)
            .top(to: ui.secondCurrencySelectionButton.edge.bottom).marginTop(24).bottom(-180)

        ui.secondCurrencyLabel.pin
            .size(of: ui.firstCurrencyLabel)
            .vCenter(to: ui.secondCurrencyTextField.edge.vCenter)
            .left(to: ui.secondCurrencyTextField.edge.right)
    }
}






