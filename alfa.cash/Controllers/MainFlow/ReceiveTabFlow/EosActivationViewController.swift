//
//  EosActivationViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 30.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore

class EosActivationViewController: BaseViewController {

    @IBOutlet weak var selectWalletView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var nextButton: BlueButton!
    @IBOutlet weak var amountLabel: TitleNoFontLabel!
    @IBOutlet weak var tagLabel: TagLabel!
    @IBOutlet weak var selectFromCoinStack: UIStackView!
    @IBOutlet weak var selectFromLabel: UILabel!
    @IBOutlet weak var coinFromImage: UIImageView!
    @IBOutlet weak var coinFromName: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textField: BorderedTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var checkMode: CheckMode = .accountCheck {
        didSet {
            if checkMode == .selectWallet {
                selectWalletView.isHidden = false
                textField.isUserInteractionEnabled = false
            }
            if checkMode == .confirmActivation {
                confirmView.isHidden = false
                nextButton.setEnable(true)
            }
        }
    }
    var wallet: Wallet!
    var account: String?
    var depositWallet: Wallet?
    var dialogView: DialogView!
    let walletDialogHeight = UIScreen.main.bounds.height - 112
    var maxBalance: BDouble? {
        didSet {
            if let min = eosMin, let max = maxBalance {
                checkAmountAvailable(min: min, max: max)
            }
        }
    }
    var eosMin: Double? {
        didSet {
            if let min = eosMin, let max = maxBalance {
                checkAmountAvailable(min: min, max: max)
            }
        }
    }
    var withdrawalMin: Double = 0
    let eosMinimum: Double = 5
    var exchangeTag: Int?
    var eosActivationId: Int?
    var orderId: String?
    private let biometryManager = BiometryManager()
    private var biometryEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Constants.Main.udBiometryEnabled)
    }
    private var transactionSecurityEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Constants.Main.udTransactionSecurityEnabled)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTransactionsNavBar(title: "\("RECEIVE".localized()) \(CoinType.eos.currency.uppercased())")
        
        nextButton.setEnable(false)
        setUpDialogView()
        
        activityIndicator.color = ThemeManager.currentTheme == .day ? .black : .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func goBack() {
        if let homeVC = navigationController?.viewControllers.first as? HomePageViewController  {
            navigationController?.popToViewController(homeVC, animated: true)
        }
    }
    
    func setupSelectWalletView(wallet: Wallet?) {
        if let wallet = wallet {
            selectFromCoinStack.isHidden = false
            selectFromLabel.isHidden = true
            let currencyName = wallet.currency == "erc20" ? "eth" : wallet.currency
            let iconName = ThemeManager.currentTheme == .day ? currencyName : "\(currencyName)_dark"
            coinFromImage.image = UIImage(named: iconName)
            coinFromName.text = wallet.title
        } else {
            selectFromCoinStack.isHidden = true
            selectFromLabel.isHidden = false
        }
    }
    
    func setupConfirmView(wallet:Wallet) {
        tagLabel.text = wallet.currency.uppercased()
    }
    
    func checkAmountAvailable(min: Double, max: BDouble) {
        print("MIN: ", min)
        if max > min {
            exchange()
        } else {
            showError(String(format: "INSUFFICIENT_TO_COMPLETE_TRANSACTION".localized(), depositWallet?.currency.uppercased() ?? "ERC20"))
        }
    }
    
    //===============================
    // IB Actions
    //===============================
    
    @IBAction func nextAction(_ sender: Any) {
        switch checkMode {
        case .accountCheck:
            if let account = account {
                checkAccount(account: account)
            }
        case .selectWallet:
            break
        case .confirmActivation:
            submitTransaction()
        }
    }
    
    @IBAction func selectWallet(_ sender: Any) {
        showDialog()
    }
    
    //===============================
    // Network
    //===============================
    
    func checkAccount(account: String) {
        nextButton.setEnable(false)
        activityIndicator.startAnimating()
        NetworkManager.checkEosAccount(walletId: wallet.id, account: account) { [weak self] (exists, error) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                if let error = error {
                    self?.showError(error)
                }
                if exists {
                    self?.showError("ERROR_EOS_ACCOUNT_EXISTS".localized())
                } else {
                    self?.checkMode = .selectWallet
                }
            }
        }
    }
    
    func prepareActivation(deposit: Wallet) {
        activityIndicator.startAnimating()
        NetworkManager.exchangePrepare(walletFromId: deposit.id, walletToId: wallet.id) { [weak self] (response, error) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                if let error = error {
                    self?.showError(error)
                }
                
                if let response = response, let eosMinimum = self?.eosMinimum {
                    self?.withdrawalMin = min(response.limits.toMin, eosMinimum)
                    self?.eosMin = response.limits.fromMin
                }
            }
        }
    }
    
    func getMaxBalance(wallet: Wallet) {
        NetworkManager.getMaximumBalance(walletId: wallet.id) { [weak self] (maxBalance, error) in
            DispatchQueue.main.async {
                if let maxBalance = maxBalance {
                    print("MAX BALANCE: ", maxBalance)
                    self?.maxBalance = BDouble(maxBalance)
                }
            }
        }
    }
    
    func exchange() {
        guard let depositWallet = depositWallet,
            let eosMin = eosMin,
            let account = account else { return }
        activityIndicator.startAnimating()
        let options = Options(accountName: account)
        NetworkManager.exchange(walletFromId: depositWallet.id, walletToId: wallet.id, amountFrom: "\(eosMin)", amountTo: "\(withdrawalMin)", isWindrawalMain: true, options: options) { [weak self] (response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                    self?.activityIndicator.stopAnimating()
                }
                if let response = response {
                    self?.eosActivationId = response.eosActivationId
                    self?.orderId = response.orderId
                    self?.createTransaction(address: response.deposit.address, exchangeTag: response.deposit.exchangeTag)
                }
            }
        }
    }
    
    func createTransaction(address: String, exchangeTag: String?) {
        guard let amount = eosMin, let depositWallet = depositWallet else { return }
        TransactionManager.createTransaction(wallet: depositWallet, address: address, amount: "\(amount)", exchangeTag: exchangeTag) { [weak self] (success) in
            self?.activityIndicator.stopAnimating()
            if success {
                guard let total = TransactionManager.totalForSpeed(.medium) else {
                    return
                }
                self?.amountLabel.text = total
                self?.checkMode = .confirmActivation
            }
        }
    }
    
    func submitTransaction() {
        if transactionSecurityEnabled {
            if biometryEnabled {
                biometryManager.authorizeUsingBiometry(success: { [weak self] in
                    DispatchQueue.main.async {
                        self?.submit()
                    }
                }, failure: nil)
            } else {
                if let vc = UIStoryboard.get(flow: .options).get(controller: .passcode) as? PasscodeViewController {
                    vc.modalPresentationStyle = .fullScreen
                    vc.mode = .transaction
                    vc.delegate = self
                    present(vc, animated: true, completion: nil)
                }
            }
        } else {
            submit()
        }
    }
    
    func submit() {
        nextButton.setEnable(false)
        TransactionManager.submitTransaction(orderId: orderId, eosActivationId: eosActivationId) { [weak self] (txId) in
            DispatchQueue.main.async {
                if txId != nil {
                    let okAction = UIAlertAction(title: "OK".localized(), style: .default) { (_) in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    self?.showAlert(title: "EOS_ACTIVATION_TITLE".localized(), message: "EOS_ACTIVATION_MESSAGE".localized(), actions: [okAction])
                } else {
                    self?.nextButton.stopLoading()
                }
            }
        }
    }
    
    //===============================
    // DIALOG VIEW
    //===============================
    
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
        dialogView.dialogType = .eosActivation
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
    
    override func handleDismiss() {
        hideDialog()
    }
    
    //===============================
    // Notifications
    //===============================
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint.constant = keyboardSize.height + 24
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = 54
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
}

extension EosActivationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
        if let text = textField.text, let textRange = Range(range, in: text) {
            let account = text.replacingCharacters(in: textRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)
            if account.isEosAccountValid() {
                nextButton.setEnable(account.count == 12)
                self.account = account.count == 12 ? account : nil
            } else {
                nextButton.setEnable(text.count == 12)
            }
            return account.isEosAccountValid()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

extension EosActivationViewController: DialogViewExchangeDelegate {
    func selectWallet(_ wallet: Wallet, type: ExchangeType) {
        hideDialog()
        depositWallet = wallet
        setupSelectWalletView(wallet: wallet)
        setupConfirmView(wallet: wallet)
        getMaxBalance(wallet: wallet)
        prepareActivation(deposit: wallet)
    }
}

extension EosActivationViewController: PassCodeDelegate {
    func passCodeDidMatch() {
        submit()
    }
}


enum CheckMode {
    case accountCheck
    case selectWallet
    case confirmActivation
}
