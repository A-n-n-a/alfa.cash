//
//  PayoutViewController.swift
//  alfa.cash
//
//  Created by Anna on 6/26/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class PayoutViewController: BaseViewController {

    @IBOutlet weak var requestPayoutButton: HeaderButton!
    @IBOutlet weak var payoutHistoryButton: HeaderButton!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var requestPayoutView: UIView!
    @IBOutlet weak var balanceLabel: TitleNoFontLabel!
    @IBOutlet weak var currencyLabel: TitleNoFontLabel!
    @IBOutlet weak var addressLabel: SubtitleLabel!
    @IBOutlet weak var errorLabel: ACLabel!
    @IBOutlet weak var coinIcon: UIImageView!
    @IBOutlet weak var nextButton: BlueButton!
    @IBOutlet weak var coinsButton: UIButton!
    
    let historyBackground = TableBackgroundView()
    var payments: [ReferralPayment] = [] {
        didSet {
            historyTableView.reloadData()
            historyBackground.alpha = payments.isEmpty ? 1 : 0
        }
    }
    
    var descendant = false
    var wallet: Wallet! {
        didSet {
            address = wallet.account
            currencyLabel.text = wallet.coin?.name
            let currencyName = wallet.currency == "erc20" ? "eth" : wallet.currency
            let iconName = ThemeManager.currentTheme == .trueNight ?"\(currencyName)_dark" : currencyName
            coinIcon.image = UIImage(named: iconName)
        }
    }
    var address = "" {
        didSet {
            addressLabel.text = "\("ADDRESS".localized()): \(address)"
        }
    }
    
    var dialogView: DialogView!
    let walletDialogHeight = UIScreen.main.bounds.height - 112
    
    let payoutRequestView = PayoutRequestView(frame: CGRect(x: 12, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width - 24, height: 414))
    var bottomConnectViewConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpHomeNavBar(title: "PAYOUT")
        setupBackground()
        
        if let btc = WalletManager.wallets.filter({ $0.coin == .bitcoin}).first {
            wallet = btc
        }
        
        historyTableView.register(cellClass: PayoutHistoryTableViewCell.self)
        
        getPayments()
        setUpDialogView()
        setupBalance()
        
        payoutRequestView.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func handleDismiss() {
        hideDialog()
        hideSuccessPopup()
    }
    
    func setupBalance() {
        if let balance = ApplicationManager.referralInfo?.balance {
            balanceLabel.text = String(format: "$%.2f", balance)
            let payoutEnable = balance >= 50
            nextButton.setEnable(payoutEnable)
            coinsButton.isEnabled = payoutEnable
            errorLabel.isHidden = payoutEnable
        }
    }
    
    func getPayments() {
        NetworkManager.getReferralPayments { [weak self] (payments, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let payments = payments {
                    self?.payments = payments
                }
            }
        }
    }
    
    func setupBackground() {
        historyBackground.setupWithTitle("NO_HISTORY_FOUND".localized(), subtitle: "KEEP_TRACK_YOUR_COMMISIONS".localized())
        historyBackground.hideIcon()
        historyTableView.backgroundView = historyBackground
    }
    
    fileprivate func setUpDialogView() {
        let frame = view.frame
        dialogView = DialogView(frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: walletDialogHeight + 30))
        dialogView.exchangeDelegate = self
        view.addSubview(dialogView)
    }
    
    func showDialog() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        dialogView.dialogType = .selectExchange
        window.addSubview(dialogView)
        blackView.frame = window.frame
        
        dialogView.resetCellsSelection()
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.dialogView.transform = CGAffineTransform(translationX: 0, y: -self.walletDialogHeight)
        }
    }
    
    func hideDialog() {
        dialogView.textField.text = ""
        dialogView.textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.dialogView.transform = .identity
        }
    }
    
    func showSuccessPopup() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        blackView.addSubview(payoutRequestView)
        payoutRequestView.translatesAutoresizingMaskIntoConstraints = false
        payoutRequestView.leadingAnchor.constraint(equalTo: blackView.leadingAnchor, constant: 12).isActive = true
        blackView.trailingAnchor.constraint(equalTo: payoutRequestView.trailingAnchor, constant: 12).isActive = true
        bottomConnectViewConstraint = blackView.bottomAnchor.constraint(equalTo: payoutRequestView.bottomAnchor, constant: 30)
        bottomConnectViewConstraint?.isActive = true
        payoutRequestView.heightAnchor.constraint(equalToConstant: 414).isActive = true
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 1
            self.blackView.layoutIfNeeded()
        }
    }
    
    func hideSuccessPopup() {
        bottomConnectViewConstraint?.constant = -500
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.blackView.layoutIfNeeded()
        }
    }

    @IBAction func chooseCurrency(_ sender: Any) {
        showDialog()
    }
    
    @IBAction func requestPayoutAction(_ sender: Any) {
        requestPayoutButton.setSelected(true)
        payoutHistoryButton.setSelected(false)
        requestPayoutView.isHidden = false
    }
    @IBAction func payoutHistoryAction(_ sender: Any) {
        payoutHistoryButton.setSelected(true)
        requestPayoutButton.setSelected(false)
        requestPayoutView.isHidden = true
    }
    @IBAction func sortAction(_ sender: Any) {
        if descendant {
            payments = payments.sorted(by: { $0.amountUsd < $1.amountUsd })
        } else {
            payments = payments.sorted(by: { $0.amountUsd > $1.amountUsd })
        }
        descendant.toggle()
        historyTableView.reloadData()
    }
    
    @IBAction func requestPayout(_ sender: Any) {
        nextButton.startLoading()
        NetworkManager.payoutRequest(walletId: wallet.id) { [weak self] (success, error) in
            if let error = error {
                self?.showError(error)
            }
            if success {
                self?.showSuccessPopup()
            }
        }
    }
}

extension PayoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(PayoutHistoryTableViewCell.self)) as! PayoutHistoryTableViewCell
        cell.payment = payments[indexPath.row]
        cell.setBackground(index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

//extension PayoutViewController: UITextFieldDelegate {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField.text == "0.00" {
//            textField.text = ""
//        }
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField.text == "" {
//            textField.text = "0.00"
//        }
//    }
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let text = textField.text, let textRange = Range(range, in: text) {
//            let query = text.replacingCharacters(in: textRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)
//            if !query.isAmountValidSigns() {
//                return false
//            }
//            let amount = query.handledFiatAmountTFText()
//            textField.text = amount
//            checkMinimum(amount: amount)
//            return false
//        }
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        view.endEditing(true)
//        return true
//    }
//}

extension PayoutViewController: DialogViewExchangeDelegate {
    func selectWallet(_ wallet: Wallet, type: ExchangeType) {
        hideDialog()
        self.wallet = wallet
    }
}

extension PayoutViewController: PayoutRequestViewDelegate {
    func dismissView() {
        hideSuccessPopup()
    }
}
