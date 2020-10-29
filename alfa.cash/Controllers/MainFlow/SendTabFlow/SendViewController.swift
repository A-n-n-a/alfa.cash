//
//  SendViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 23.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore

class SendViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var maximumLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var recentAddressesButton: ACButton!
    @IBOutlet weak var addressTextField: ACTextField!
    @IBOutlet weak var sendButton: BlueButton!
    @IBOutlet weak var errorLabel: ACLabel!
    @IBOutlet weak var verticalLeftView: UIView!
    @IBOutlet weak var verticalRightView: UIView!
    @IBOutlet weak var memoView: BorderedThemedView!
    @IBOutlet weak var memoTextField: ClearTextField!
    
    var wallet: Wallet?
    var amount: String? {
        didSet {
            if sendButton != nil {
                updateButton()
            }
            guard let tableView = tableView, let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AmountTableViewCell else { return }
            cell.setAmount(amount ?? "0.00")
        }
    }
    var address: String? {
        didSet {
            if sendButton != nil {
                bchWarningShown = false
                updateButton()
                checkOwnAddress(address)
            }
        }
    }
    
    var addressesView: SpeedView!
    let addressViewHeight: CGFloat = 360
    var isAmountValid = true
    var hasWalletError = false {
        didSet {
            errorLabel.isHidden = !hasWalletError
        }
    }
    
    var maximumAmount: String? {
        didSet {
            if let maximumAmount = maximumAmount {
                maximumLabel.text = "\("MAXIMUM_AMOUNT_TO_SEND".localized()): \(maximumAmount)" 
            }
        }
    }
    
    var dialogView: DialogView!
    let walletDialogHeight = UIScreen.main.bounds.height - 112
    var bchWarningShown = false
    
    private var stellarRegex = "^[a-zA-Z0-9]{0,28}$"
    private var eosRegex = "^[a-zA-Z0-9]{0,256}$"
    private var xrpRegex = "^[0-9]{0,10}$"
    private var currentRegex: String?
    
    var destinationTag: Int? {
        didSet {
            if let destinationTag = destinationTag {
                memoTextField.text = "\(destinationTag)"
            }
        }
    }
    var memo: String? {
        didSet {
            memoTextField.text = memo
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTransactionsNavBar(title: "SEND_CRYPTO".localized())
        refreshWallets()
        getMaxBalance()
        setUpUI()
        getRecentAddresses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        bchWarningShown = false
        setupMemo()
    }
    
    func setUpUI() {
        
        tableView.register(cellClass: CoinTableViewCell.self)
        tableView.register(cellClass: AmountTableViewCell.self)
        
        containerView.layer.borderColor = ThemeManager.currentTheme.associatedObject.textFieldBorderColor.cgColor
        containerView.layer.borderWidth = 2
        
        if let address = address {
            addressTextField.text = address
            checkOwnAddress(address)
        }
        
        updateButton()
        
        recentAddressesButton.contentHorizontalAlignment = .left
        
        let frame = view.frame
        addressesView = SpeedView(frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: addressViewHeight + 30))
        addressesView.mode = .addresses
        addressesView.delegate = self
        view.addSubview(addressesView)
        
        
        dialogView = DialogView(frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: walletDialogHeight + 30))
        dialogView.dialogType = .send
        dialogView.navigationDelegate = self
        view.addSubview(dialogView)
        
        verticalLeftView.backgroundColor = ThemeManager.currentTheme.associatedObject.textFieldBorderColor
        verticalRightView.backgroundColor = ThemeManager.currentTheme.associatedObject.textFieldBorderColor
    }
    
    func setupMemo() {
        guard let coin = wallet?.coin else { return }
        switch coin {
        case .xrp:
            memoView.isHidden = false
            memoTextField.placeholderKey = "DESTINATION_TAG"
            currentRegex = xrpRegex
        case .stellar:
            memoView.isHidden = false
            memoTextField.placeholderKey = "MEMO"
            currentRegex = stellarRegex
        case .eos:
            memoView.isHidden = false
            memoTextField.placeholderKey = "MEMO"
            currentRegex = eosRegex
        default:
            memoView.isHidden = true
        }
    }
    
    func isMemoValid(_ memo: String) -> Bool {
        guard let regex = currentRegex else { return false }
        return memo.isMemoValid(regex: regex)
    }
    
    func updateButton() {
        
        guard wallet != nil, amount != nil, address != nil, !hasWalletError else {
            sendButton.setEnable(false)
            return
        }
        
        guard isAmountValid && address?.isAddressValid() ?? false else {
            sendButton.setEnable(false)
            return
        }
        
        guard let amount = amount, let doubleAmount = Double(amount), doubleAmount > 0 else  {
            sendButton.setEnable(false)
            return
        }
        
        sendButton.setEnable(true)
    }
    
    func showCoinsDialog() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        window.addSubview(dialogView)
        blackView.frame = window.frame
        
        dialogView.resetCellsSelection()
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.dialogView.transform = CGAffineTransform(translationX: 0, y: -self.walletDialogHeight)
        }
    }
    
    func hideCoinsDialog() {
        dialogView.textField.text = ""
        dialogView.textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.dialogView.transform = .identity
        }
    }
    
    func getMaxBalance() {
        guard let wallet = wallet else { return }
        NetworkManager.getMaximumBalance(walletId: wallet.id) { [weak self] (maxBalance, error) in
            DispatchQueue.main.async {
                if let maxBalance = maxBalance {
                    self?.maximumAmount = maxBalance
                }
                if error != nil {
                    self?.maximumAmount = "0.00"
                }
            }
        }
    }
    
    func checkOwnAddress(_ address: String?) {
        if let address = address, address == wallet?.account {
            hasWalletError = true
            sendButton.setEnable(false)
        } else {
            hasWalletError = false
            updateButton()
        }
    }
    
    func refreshWallets() {
        getWallets { [weak self] (success) in
            DispatchQueue.main.async {
                if success {
                    if let wallet = WalletManager.wallets.filter({ $0.id == self?.wallet?.id }).first {
                        self?.wallet = wallet
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func getRecentAddresses() {
        guard let wallet = wallet else { return }
        NetworkManager.getTransactions(currency: wallet.currency, pageSize: 3, type: .send) { [weak self] (transactions, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.recentAddressesButton.isHidden = true
                }
                if let transactions = transactions {
                    self?.recentAddressesButton.isHidden = false
                    let addresses = transactions.compactMap { (transaction) -> String? in
                        return transaction.toAddress
                    }
                    WalletManager.recentAddresses = addresses.filter({ !$0.isEmpty})
                    self?.recentAddressesButton.isHidden = WalletManager.recentAddresses.isEmpty
                    self?.addressesView.updateContent()
                }
            }
        }
    }
    
    func moveToNextScreen() {
        guard let address = address else { return }
        if let vc = UIStoryboard.get(flow: .sendFlow).get(controller: .completeSend) as? CompleteSendViewController {
            vc.address = address
            vc.destinationTag = destinationTag
            vc.exchangeTag = memo
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func selectAddress(_ sender: Any) {
        showDialog()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        guard let wallet = wallet, let address = address else { return }
        
        if wallet.coin == .bitcoinCash && !(address.contains(words: "bitcoincash:") || address.contains(words: "bchtest:")) {
            if !bchWarningShown {
                let okAction = UIAlertAction(title: "OK".localized(), style: .default) { (_) in
                    self.sendAction()
                }
                let cancelAction = UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil)
                showAlert(title: nil, message: "BCH_WARNING".localized(), actions: [okAction, cancelAction])
                bchWarningShown = true
                return
            }
        }
        
        sendAction()
    }
    
    func sendAction() {
        guard let wallet = wallet, let amount = amount, let address = address else { return }
        sendButton.startLoading()
        TransactionManager.createTransaction(wallet: wallet, address: address, amount: amount, exchangeTag: memo, destinationTag: destinationTag, completion: { [weak self] (success) in
            DispatchQueue.main.async {
                if success {
                    self?.moveToNextScreen()
                }
                self?.sendButton.stopLoading()
            }
        })
    }
    
    @IBAction func openCamera(_ sender: Any) {
        if let vc = UIStoryboard.get(flow: .sendFlow).get(controller: .camera) as? CameraViewController {
            view.endEditing(true)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func maxAmountAction(_ sender: Any) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AmountTableViewCell{
            amount = maximumAmount
            cell.amount = maximumAmount
            updateButton()
        }
    }
    
    func showDialog() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        window.addSubview(addressesView)
        blackView.frame = window.frame
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.addressesView.transform = CGAffineTransform(translationX: 0, y: -self.addressViewHeight)
        }
    }
    
    func hideDialog() {
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.addressesView.transform = .identity
        }
    }
    
    override func handleDismiss() {
        hideDialog()
        hideCoinsDialog()
    }
    
    func checkAddress(_ address: String?) {
        if let address = address {
            if address.isAddressValid() {
                containerView.backgroundColor = ThemeManager.currentTheme.associatedObject.textfieldBackgroundColor
            } else {
                containerView.backgroundColor = UIColor.kErrorColor.withAlphaComponent(0.3)
            }
        } else {
            containerView.backgroundColor = ThemeManager.currentTheme.associatedObject.textfieldBackgroundColor
        }
    }
}

extension SendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let wallet = wallet else { return UITableViewCell() }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(CoinTableViewCell.self)) as! CoinTableViewCell
            cell.wallet = wallet
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(AmountTableViewCell.self)) as! AmountTableViewCell
            cell.currency = wallet.coin
            if let amount = amount {
                cell.amount = amount
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 85
        }
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showCoinsDialog()
        } else {
            if let exchangeAmountVC = UIStoryboard.get(flow: .exchangeFlow).get(controller: .exchangeAmountVC) as? ExchangeAmountViewController {
                exchangeAmountVC.delegate = self
                exchangeAmountVC.exchangeType = indexPath.row == 0 ? .from : .to
                exchangeAmountVC.wallet = wallet
                exchangeAmountVC.availableAmount = maximumAmount ?? ""
                exchangeAmountVC.price = wallet?.price
                navigationController?.pushViewController(exchangeAmountVC, animated: true)
            }
        }
    }
}

extension SendViewController: QRCodeScannerDelegate {
    func scannerDidFinishWithResult(_ result: String) {
        address = result
        addressTextField.text = address
    }
    
    func scannerDidFinishWithError(_ error: String?) {
        if let error = error {
            self.showError(error)
        }
    }
}

extension SendViewController: ExchangeAmountViewControllerDelegate {
    func setAmount(_ amount: String, type: ExchangeType, fromCell: Bool) {
        self.amount = amount
    }
}

extension SendViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let result = text.replacingCharacters(in: textRange, with: string)
            if textField == memoTextField {
                let valid = isMemoValid(result)
                if valid {
                    if wallet?.coin == .xrp {
                        if let tag = Int(result) {
                            destinationTag = tag
                        }
                    } else {
                        memo = result
                    }
                }
                return valid
            }
            address = result
            checkAddress(address)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension SendViewController: SpeedViewDelegate {
    func speedSelected() {
        
    }
    
    func addressSelected(_ address: String) {
        self.address = address
        addressTextField.text = address
        handleDismiss()
    }
}

extension SendViewController: DialogViewNavigationDelegate {
    func goToExchange(wallet: Wallet) {
        
    }
    
    func goToReceive(wallet: Wallet) {
    }
    
    func goToSend(wallet: Wallet) {
        self.wallet = wallet
        self.amount = ""
        getMaxBalance()
        tableView.reloadData()
        addressTextField.text = ""
    }
    
    func showDialog(_ show: Bool) {
        hideCoinsDialog()
    }
}
