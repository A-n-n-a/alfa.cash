//
//  ExchangeViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 23.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class ExchangeViewController: BaseViewController {
    
    @IBOutlet weak var selectFromCoinStack: UIStackView!
    @IBOutlet weak var selectFromLabel: UILabel!
    @IBOutlet weak var coinFromImage: UIImageView!
    @IBOutlet weak var coinFromName: UILabel!
    @IBOutlet weak var selectToCoinStack: UIStackView!
    @IBOutlet weak var selectToLabel: UILabel!
    @IBOutlet weak var coinToImage: UIImageView!
    @IBOutlet weak var coinToName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var nextButton: BlueButton!
    
    @IBOutlet weak var speedContainerView: UIView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var speedButtonLabel: UILabel!
    
    @IBOutlet weak var firstCoinButton: UIButton!
    @IBOutlet weak var secondCoinButton: UIButton!
    @IBOutlet weak var rateActivityIndicator: UIActivityIndicatorView!
    
    var walletFrom: Wallet?
    var walletTo: Wallet?
    var amountFrom: String? {
        didSet {
            if !nextButton.isLoading {
                updateButton()
            }
        }
    }
    var amountTo: String? {
        didSet {
            if !nextButton.isLoading {
                updateButton()
            }
        }
    }
    var dialogView: DialogView!
    let walletDialogHeight = UIScreen.main.bounds.height - 112
    var exchangeInfo: ExchangePrepare?
    var rate: String? {
        didSet {
            guard let cellFrom = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ExchangeTableViewCell,
                       let cellTo = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ExchangeTableViewCell else { return }
            if let amount = amountFrom, amountTo == nil {
                amountTo = calculateToAmount(amount)
                cellTo.amount = amountTo
            }
            
            if let amount = amountTo, amountFrom == nil {
                amountFrom = calculateFromAmount(amount)
                cellFrom.amount = amountFrom
            }
        }
    }
    
    var isWindrawalMain = false
    var address = ""
    var speedView: SpeedView?
    let speedViewHeight: CGFloat = 360
    var exchangeMode: ExchangeMode = .prepare {
        didSet {
            if exchangeMode == .timer {
                enableInteraction(false)
                updateSpeedView()
                collectionView.isHidden = true
                pageControll.isHidden = true
                speedContainerView.isHidden = false
                if oldValue != exchangeMode {
                    startTimer()
                }
            } else {
                enableInteraction(true)
                collectionView.isHidden = false
//                pageControll.isHidden = false
                speedContainerView.isHidden = true
                deactivateTimer()
                nextButton.setTitle("EXCHANGE_CRYPTO".localized(), for: .normal)
            }
        }
    }
    
    var timer: Timer?
    var time = 300
    var isInteractionAllowed = true
    var orderId: String?
    var destinationTag: Int?
    var exchangeTag: String?
    private let biometryManager = BiometryManager()
    private var biometryEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Constants.Main.udBiometryEnabled)
    }
    private var transactionSecurityEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Constants.Main.udTransactionSecurityEnabled)
    }
    
    var fromMin: Double?
    var toMin: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTransactionsNavBar(title: "EXCHANGE_CURRENCY".localized())
        
        setUpDialogView()
        updateButton()
        
        tableView.register(cellClass: ExchangeTableViewCell.self)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        setUpCoinFrom(wallet: walletFrom)
        
        if let walletFrom = walletFrom, let walletTo = walletTo {
            prepareExchange(walletFrom: walletFrom, walletTo: walletTo)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    //===============================
    // UI
    //===============================
    
    func setUpSpeedUI() {
        let frame = view.frame
        speedView = SpeedView(frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: speedViewHeight + 30))
        speedView?.delegate = self
        speedView?.mode = .speed
        speedView?.metas = TransactionManager.transactionResponse?.meta.sorted(by: { $0.value > $1.value })
        if let speedView = speedView {
            view.addSubview(speedView)
        }
    }
    
    func updateSpeedView() {
        let speed = TransactionManager.speed
        speedLabel.text = speed.localizedKey.localized()
        if let fee = TransactionManager.feeForSpeed(TransactionManager.speed), let currency = walletFrom?.currency.uppercased() {
            feesLabel.text = "\("NETWORK_FEE".localized()): \(fee) \(currency)"
        }
        if TransactionManager.transactionResponse?.prioritySupport ?? false && !TransactionManager.speedButtonShouldHide {
            hideSpeedButton(false)
        } else {
            hideSpeedButton(true)
        }
        
        speedLabel.isHidden = !(TransactionManager.transactionResponse?.prioritySupport ?? false)
    }
    
    func hideSpeedButton(_ hide: Bool) {
        speedButton.isHidden = hide
        speedButtonLabel.isHidden = hide
    }
    
    func showSpeedDialog() {
        guard let window = window, let speedView = speedView else { return }
        window.addSubview(blackView)
        window.addSubview(speedView)
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.speedView?.transform = CGAffineTransform(translationX: 0, y: -self.speedViewHeight)
        }
    }
    
    func hideSpeedDialog() {
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.speedView?.transform = .identity
        }
    }
    
    func updateButton() {
        nextButton.setEnable(amountFrom != nil && amountTo != nil)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            self.nextButton.stopLoading()
            if self.time > 0 {
                var timerText = ""
                self.time -= 1
                if self.time < 60 {
                    timerText = self.time/10 == 0 ? "0:0\(self.time)" : "0:\(self.time)"
                } else {
                    let minutes = self.time/60
                    let seconds = self.time - (minutes * 60)
                    let secondsString = seconds/10 == 0 ? "0\(minutes)" : "\(seconds)"
                    timerText = "\(minutes):\(secondsString)"
                }
                let title = "\("EXCHANGE_CRYPTO".localized()) | \(timerText)"
                self.nextButton.setTitle(title, for: .normal)
            } else {
                let retryAction = UIAlertAction(title: "OK".localized(), style: .default) { (_) in
                    self.retry()
                }
                let cancelAction = UIAlertAction(title: "CANCEL".localized(), style: .cancel) { (_) in
                    self.navigationController?.popViewController(animated: true)
                }
                self.showAlert(title: nil, message: "EXCHANGE_IS_EXPIRED".localized(), actions: [retryAction, cancelAction])
                self.nextButton.setEnable(false)
                self.deactivateTimer()
            }
        })
    }
    
    func retry() {
        time = 300
        exchangeMode = .prepare
        updateButton()
//        amountFrom = initialAmountFrom
//        initialAmountFrom = nil
//        amountTo = initialAmountTo
//        initialAmountTo = nil
        
        setAmount(amountFrom ?? "0.00", type: .from, fromCell: false)
        setAmount(amountTo ?? "0.00", type: .to, fromCell: false)
        rateLabel.text = getRateText(rate: rate)
    }
    
    func deactivateTimer() {
        if timer?.isValid ?? false {
            timer?.invalidate()
        }
    }
    
    func enableInteraction(_ enable: Bool) {
        isInteractionAllowed = enable
        firstCoinButton.isUserInteractionEnabled = enable
        secondCoinButton.isUserInteractionEnabled = enable
    }
    
    func getRateText(rate: String?) -> String? {
        guard let rate = rate, let walletFrom = walletFrom, let walletTo = walletTo else { return nil }
        let rateText = "EXCHANGE_RATE".localized() + String(format: ": 1 %@ = %@ %@",
        walletFrom.currency.uppercased(),
        rate,
        walletTo.currency.uppercased())
        return rateText
    }
    
    //===============================
    // COINS VIEWS
    //===============================
    
    func setUpCoinFrom(wallet: Wallet?) {
        walletFrom = wallet
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
    
    func setUpCoinTo(wallet: Wallet?) {
        walletTo = wallet
        if let wallet = wallet {
            selectToCoinStack.isHidden = false
            selectToLabel.isHidden = true
            let currencyName = wallet.currency == "erc20" ? "eth" : wallet.currency
            let iconName = ThemeManager.currentTheme == .day ? currencyName : "\(currencyName)_dark"
            coinToImage.image = UIImage(named: iconName)
            coinToName.text = wallet.title
        } else {
            selectToCoinStack.isHidden = true
            selectToLabel.isHidden = false
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
    
    func showDialog(exchangeType: ExchangeType = .from) {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        dialogView.exchangeType = exchangeType
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
    
    override func handleDismiss() {
        hideDialog()
        hideSpeedDialog()
    }
    
    //===============================
    // Network
    //===============================
    
    func prepareExchange(walletFrom: Wallet, walletTo: Wallet) {
        isInteractionAllowed = false
        rateLabel.isHidden = true
        rateActivityIndicator.startAnimating()
        NetworkManager.exchangePrepare(walletFromId: walletFrom.id, walletToId: walletTo.id, amountFrom: self.amountFrom, amountTo: self.amountTo, isWindrawalMain: (amountFrom == nil && amountTo == nil) ? nil : isWindrawalMain) { [weak self] (response, error) in
            DispatchQueue.main.async {
                self?.rateActivityIndicator.stopAnimating()
                self?.isInteractionAllowed = true
                if let error = error {
                    self?.showError(error)
                }
                
                if let response = response {
                    self?.exchangeInfo = response
                    self?.rate = response.rates.rate
                    self?.rateLabel.isHidden = false
                    self?.rateLabel.text = self?.getRateText(rate: response.rates.rate)
                    self?.fromMin = response.limits.fromMin
                    self?.toMin = response.limits.toMin
                }
            }
        }
    }
    
    func exchange() {
        guard let walletFrom = walletFrom,
            let walletTo = walletTo,
            let amountFrom = amountFrom,
            let amountTo = amountTo,
            let amountMinFrom = fromMin,
            let amountMinTo = toMin else { return }
        
        if isWindrawalMain {
            self.amountFrom = max((BDouble(amountFrom) ?? 0), BDouble(amountMinFrom)).stringValue() ?? ""
        } else {
            self.amountTo = max((BDouble(amountTo) ?? 0), BDouble(amountMinTo)).stringValue() ?? ""
        }
        
        nextButton.startLoading()
        NetworkManager.exchange(walletFromId: walletFrom.id, walletToId: walletTo.id, amountFrom: self.amountFrom ?? "", amountTo: self.amountTo ?? "", isWindrawalMain: isWindrawalMain) { [weak self] (response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.nextButton.stopLoading()
                    self?.showError(error)
                }
                if let response = response {
                    let address = response.deposit.address
                    self?.exchangeTag = response.deposit.exchangeTag
                    self?.destinationTag = response.deposit.destinationTag
                    self?.createTransaction(address: address, exchangeTag: self?.exchangeTag, destinationTag: self?.destinationTag)
                    self?.orderId = response.orderId

                    if let doubleTo = BDouble(response.amountTo), let doubleFrom = BDouble(response.amountFrom) {
                        let newRateDouble = doubleTo / doubleFrom
                        self?.rateLabel.text = self?.getRateText(rate: newRateDouble.decimalExpansion(precisionAfterDecimalPoint: 8))
                    }
                    
                    self?.setAmount(response.amountFrom, type: .from, fromCell: false)
                    self?.setAmount(response.amountTo, type: .to, fromCell: false)
                }
            }
        }
    }
    
    func createTransaction(address: String, exchangeTag: String?, destinationTag: Int?) {
        guard let wallet = walletFrom, let amount = amountFrom else { return }
        TransactionManager.createTransaction(wallet: wallet, address: address, amount: amount, exchangeTag: exchangeTag, destinationTag: destinationTag) { [weak self] (success) in
            if success {
                self?.setUpSpeedUI()
                self?.exchangeMode = .timer
            } else {
                self?.nextButton.stopLoading()
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
        TransactionManager.submitTransaction(orderId: orderId, destinationTag: destinationTag, exchangeTag: exchangeTag) { [weak self] (txId) in
            DispatchQueue.main.async {
                if let txId = txId {
                    self?.passToSuccessScreen(txId: txId)
                } else {
                    self?.nextButton.stopLoading()
                }
            }
        }
    }
    
    //===============================
    // IB Actions
    //===============================
    
    @IBAction func selectCoinFrom(_ sender: Any) {
        showDialog()
    }
    
    @IBAction func selectCoinTo(_ sender: Any) {
        showDialog(exchangeType: .to)
    }
    
    @IBAction func swapAction(_ sender: Any) {
        guard isInteractionAllowed else { return }
        let tempWallet = walletFrom
        walletFrom = walletTo
        walletTo = tempWallet
        setUpCoinFrom(wallet: walletFrom)
        setUpCoinTo(wallet: walletTo)
        
        
        amountFrom = nil
        amountTo = nil
        tableView.reloadData()
        
        isWindrawalMain.toggle()
        
        if let walletFrom = walletFrom, let walletTo = walletTo {
            prepareExchange(walletFrom: walletFrom, walletTo: walletTo)
        }
    }
    
    @IBAction func changeSpeed(_ sender: Any) {
        showSpeedDialog()
    }
    
    @IBAction func exchangeAction(_ sender: Any) {
        switch exchangeMode {
        case .prepare:
            exchange()
        case .timer:
            submitTransaction()
        }
    }
    
    override func goBack() {
        switch exchangeMode {
        case .prepare:
            super.goBack()
        case .timer:
            exchangeMode = .prepare
        }
    }
    
    func passToSuccessScreen(txId: String) {
        if let homeVC = navigationController?.viewControllers.first as? HomePageViewController, let exchangeCompletedVC = UIStoryboard.get(flow: .exchangeFlow).get(controller: .exchangeCompletedVC) as? ExchangeCompletedViewController {
            exchangeCompletedVC.txId = txId
            exchangeCompletedVC.address = address
            exchangeCompletedVC.walletTo = walletTo
            exchangeCompletedVC.amountTo = amountTo
            WalletManager.appendRecentAddress(address)
            navigationController?.setViewControllers([homeVC, exchangeCompletedVC], animated: true)
        }
    }
}

extension ExchangeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(ExchangeTableViewCell.self)) as! ExchangeTableViewCell
        if indexPath.row == 0 {
            cell.type = .from
            cell.coin = walletFrom?.coin
        } else {
            cell.type = .to
            cell.coin = walletTo?.coin
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard walletTo != nil, walletFrom != nil, isInteractionAllowed else { return }
        if let exchangeAmountVC = UIStoryboard.get(flow: .exchangeFlow).get(controller: .exchangeAmountVC) as? ExchangeAmountViewController {
            exchangeAmountVC.delegate = self
            exchangeAmountVC.exchangeType = indexPath.row == 0 ? .from : .to
            exchangeAmountVC.wallet = indexPath.row == 0 ? walletFrom : walletTo
            exchangeAmountVC.exchangeInfo = self.exchangeInfo
            exchangeAmountVC.price = indexPath.row == 0 ? walletFrom?.price : walletTo?.price
            navigationController?.pushViewController(exchangeAmountVC, animated: true)
        }
    }
}

extension ExchangeViewController: DialogViewExchangeDelegate {
    func selectWallet(_ wallet: Wallet, type: ExchangeType) {
        hideDialog()
        exchangeMode = .prepare
        var indexPath: IndexPath
        if type == .from {
            amountFrom = nil
            setUpCoinFrom(wallet: wallet)
            indexPath = IndexPath(row: 0, section: 0)
            if wallet.currency == walletTo?.currency {
                walletTo = nil
                amountTo = nil
                tableView.reloadData()
                setUpCoinTo(wallet: walletTo)
            }
        } else {
            address = wallet.account
            amountTo = nil
            setUpCoinTo(wallet: wallet)
            indexPath = IndexPath(row: 1, section: 0)
            if wallet.currency == walletFrom?.currency {
                walletFrom = nil
                amountFrom = nil
                tableView.reloadData()
                setUpCoinFrom(wallet: walletFrom)
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? ExchangeTableViewCell {
            cell.coin = wallet.coin
        }
        
        if let walletFrom = walletFrom, let walletTo = walletTo {
            prepareExchange(walletFrom: walletFrom, walletTo: walletTo)
        }
    }
}


extension ExchangeViewController: ExchangeAmountViewControllerDelegate {
    func setAmount(_ amount: String, type: ExchangeType, fromCell: Bool) {
        guard let cellFrom = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ExchangeTableViewCell,
            let cellTo = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ExchangeTableViewCell else { return }
        if type == .from {
            if fromCell {
                isWindrawalMain = false
                amountFrom = amount
                amountTo = calculateToAmount(amount)
                cellTo.amount = amountTo
            }
            cellFrom.amount = amount
        } else {
            if fromCell {
                isWindrawalMain = true
                amountTo = amount
                amountFrom = calculateFromAmount(amount)
                cellFrom.amount = amountFrom
            }
            cellTo.amount = amount
        }
    }
    
    func calculateToAmount(_ amount: String) -> String {
        if let doubleAmount = BDouble(amount), let rate = rate, let doubleRate = BDouble(rate) {
            let result = doubleAmount * doubleRate
            if let denominator  = result.denominator.first {
                let afterDecimalPoint = String(denominator).count - 1
                let string = result.decimalExpansion(precisionAfterDecimalPoint: min(afterDecimalPoint, 8))
                return string
            }
        }
        return ""
    }
    
    func calculateFromAmount(_ amount: String) -> String {
        if let doubleAmount = BDouble(amount), let rate = rate, let doubleRate = BDouble(rate) {
            let result = doubleAmount / doubleRate
            if let denominator  = result.denominator.first {
                let afterDecimalPoint = String(denominator).count - 1
                let string = result.decimalExpansion(precisionAfterDecimalPoint: min(afterDecimalPoint, 8))
                return string
            }
        }
        return ""
    }
}

extension ExchangeViewController: SpeedViewDelegate {
    func speedSelected() {
        updateSpeedView()
        handleDismiss()
    }
    
    func addressSelected(_ address: String) {

    }
}

enum ExchangeMode {
    case prepare
    case timer
}

extension ExchangeViewController: PassCodeDelegate {
    func passCodeDidMatch() {
        submit()
    }
}
