//
//  ExchangeAmountViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 31.03.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol ExchangeAmountViewControllerDelegate {
    func setAmount(_ amount: String, type: ExchangeType, fromCell: Bool)
}

class ExchangeAmountViewController: BaseViewController {
    
    @IBOutlet weak var minimalAmountLabel: UILabel!
    @IBOutlet weak var addCoinLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fiatLabel: UILabel!
    @IBOutlet weak var maxButton: BorderedButton!
    @IBOutlet weak var halfButton: BorderedButton!
    @IBOutlet weak var quarterButton: BorderedButton!
    @IBOutlet weak var nextButton: BlueButton!
    @IBOutlet weak var minimumAmountButton: UIButton!
    @IBOutlet weak var maxButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: KeyboardButton!
    
    
    var wallet: Wallet?
    var delegate: ExchangeAmountViewControllerDelegate?
    var exchangeType: ExchangeType = .from
    var exchangeInfo: ExchangePrepare?
    var price: Double?
    var availableAmount = ""
    var minAmount: Double = 0
    var amount = "" {
        didSet {
            amountLabel.text = amount.isEmpty ? "0" : amount
            setFiat(amount: amount)
            updateButton()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBar()
        setUpUI()
        updateButton()
        
        setFiat(amount: "0.00")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteOne))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteAll))
        tapGesture.numberOfTapsRequired = 1
        deleteButton.addGestureRecognizer(tapGesture)
        deleteButton.addGestureRecognizer(longGesture)
    }
    
    func setUpNavigationBar() {
        var coinName = ""
        var available = ""
        if let exchangeInfo = exchangeInfo {
            coinName = exchangeType == .from ? exchangeInfo.limits.gateDeposit.capitalized : exchangeInfo.limits.gateWithdrawal.capitalized
            availableAmount = exchangeType == .from ?  exchangeInfo.depositInfo.maxBalance : exchangeInfo.withdrawalInfo.maxBalance
        } else if let coin = wallet?.coin {
            coinName = coin.name
        }
        
        available = "\(availableAmount) \("AVAILABLE".localized())"
        setUpTransactionsNavBar(title: coinName, subtitle: available)
    }
    
    func setUpUI() {
        var coinCode = ""
        if let exchangeInfo = exchangeInfo {
            minAmount = exchangeType == .from ? exchangeInfo.limits.fromMin : exchangeInfo.limits.toMin
            guard let coinCodeFrom = exchangeInfo.rates.pair.components(separatedBy: "_").first,
                let coinCodeTo = exchangeInfo.rates.pair.components(separatedBy: "_").last else { return }
            coinCode = exchangeType == .from ? coinCodeFrom : coinCodeTo
            minimalAmountLabel.text = "\("MINIMAL_EXCHANGE_AMOUNT".localized()) \(minAmount) \(coinCode)"
            
        } else if let coin = wallet?.coin {
            minimalAmountLabel.isHidden = true
            coinCode = coin.currency.uppercased()
            minimumAmountButton.isEnabled = false
        }
        
        let size: CGSize = "SET_MAX".localized().size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)])
        maxButtonWidth.constant = size.width + 30
        view.layoutIfNeeded()
        addCoinLabel.text = "\("ADD".localized()) \(coinCode)"
    }
    
    func getMaxDevided(by devider: Int) -> String {
        if let maxDouble = BDouble(availableAmount) {
            let devided = maxDouble / BDouble(integerLiteral: devider)
            if let afterDecimalPoint = availableAmount.components(separatedBy: ".").last {
                let afterPointCount = afterDecimalPoint.count
                let string = devided.decimalExpansion(precisionAfterDecimalPoint: min(afterPointCount, 8))
                return string
            }
        }
        
        return ""
    }
    
    func setFiat(amount: String) {
        if let amountDouble = BDouble(amount), let price = self.price {
            let bDoublePrice = BDouble(price)
            let fiat = amountDouble * bDoublePrice
            
            fiatLabel.text = "\(FiatManager.currentFiat.sign) \(fiat.decimalExpansion(precisionAfterDecimalPoint: 2))"
        }
    }
    
    func updateButton() {
        let doubleAmount = Double(amount)
        let disable = amount.isEmpty || amount == "0" || doubleAmount == nil || doubleAmount == 0
        nextButton.setEnable(!disable)
    }
    
    @IBAction func addMax(_ sender: Any) {
        maxButton.setSelected(true)
        halfButton.setSelected(false)
        quarterButton.setSelected(false)
        
        amount = availableAmount
    }
    
    @IBAction func addHalf(_ sender: Any) {
        maxButton.setSelected(false)
        halfButton.setSelected(true)
        quarterButton.setSelected(false)
        
        amount = getMaxDevided(by: 2)
    }
    
    @IBAction func addQuarter(_ sender: Any) {
        maxButton.setSelected(false)
        halfButton.setSelected(false)
        quarterButton.setSelected(true)
        
        amount = getMaxDevided(by: 4)
    }
    
    @IBAction func addMinimum(_ sender: Any) {
        amount = "\(minAmount)"
    }
    
    @IBAction func typingAmount(_ sender: UIButton) {
        
        vibrate()
        
        maxButton.setSelected(false)
        halfButton.setSelected(false)
        quarterButton.setSelected(false)
        
        switch sender.tag {
        case 10: //0
            addNumberToAmount("0")
        case 12: // dot
            addNumberToAmount(".")
        default:
            addNumberToAmount("\(sender.tag)")
        }
    }
    
    @objc func deleteOne() {
        vibrate()
        if amount.isEmpty {
            return
        }
        amount.removeLast()
    }
    
    @objc func deleteAll() {
        if amount.isEmpty {
            return
        }
        vibrate()
        if amount.isEmpty {
            return
        }
        amount = ""
    }
    
    func vibrate() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.impactOccurred()
    }
    
    func addNumberToAmount(_ number: String) {
        
        if number == "." {
            if amount.isEmpty {
                amount.append("0.")
                return
            }
            if amount.contains(".") {
                return
            }
        }
        if number == "0", amount == "0" {
            return
        }
        if number != "0", number != ".",amount == "0" {
            amount = number
            return
        }
        amount.append(number)
        checkMinimum()
        checkMaximum()
    }
    
    func checkMinimum() {
        if let amountDouble = Double(amount) {
            minimalAmountLabel.textColor = minAmount > amountDouble ? UIColor.kErrorColor : ThemeManager.currentTheme.associatedObject.textColor
        }
    }
    
    func checkMaximum() {
        if let amountDouble = Double(amount), let maxAmount = Double(availableAmount) {
            subtitleLabel?.textColor = maxAmount < amountDouble ? UIColor.kErrorColor : ThemeManager.currentTheme.associatedObject.textColor
        }
    }
    
    @IBAction func addAmount(_ sender: Any) {
        delegate?.setAmount(amount, type: exchangeType, fromCell: true)
        navigationController?.popViewController(animated: true)
    }
}
