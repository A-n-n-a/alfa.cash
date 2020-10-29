//
//  TopUpViewController.swift
//  alfa.cash
//
//  Created by Anna on 8/19/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore
import JTMaterialSpinner

class TopUpViewController: BaseViewController {

    @IBOutlet weak var stepsLabel: ACLabel!
    @IBOutlet weak var stepNameLabel: ACLabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneLabel: TitleNoFontLabel!
    @IBOutlet weak var operatorsContainer: UIView!
    @IBOutlet weak var operatorsCollectionView: UICollectionView!
    @IBOutlet weak var operatorsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var continueView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var operatorView: UIView!
    @IBOutlet weak var operatorIconContainer: UIView!
    @IBOutlet weak var operatorIcon: CustomImageView!
    @IBOutlet weak var operatorName: TitleNoFontLabel!
    
    @IBOutlet weak var packagesContainer: UIView!
    @IBOutlet weak var currencyLabel: SubtitleLabel!
    @IBOutlet weak var packagesCollectionView: UICollectionView!
    @IBOutlet weak var rateLabel: SubtitleLabel!
    @IBOutlet weak var otherAmountView: UIView!
    @IBOutlet weak var otherAmountTextField: BorderedTextField!
    @IBOutlet weak var totalOtherAmount: SubtitleLabel!
    @IBOutlet weak var minButton: UIButton!
    @IBOutlet weak var maxButton: UIButton!
    @IBOutlet weak var otherAmountCurrencyLabel: BlueLabelOpacity!
    
    @IBOutlet weak var currencyView: UIView!
    @IBOutlet weak var currencyName: TitleNoFontLabel!
    @IBOutlet weak var currencyIcon: CustomImageView!
    @IBOutlet weak var fiatValueLabel: SubtitleLabel!
    @IBOutlet weak var currencyValueLabel: TitleLabel!
    
    @IBOutlet weak var selectedAmountView: UIView!
    @IBOutlet weak var selectedAmountValue: TitleNoFontLabel!
    
    @IBOutlet weak var receiveAmountView: UIView!
    @IBOutlet weak var receiveAmountLabel: TitleNoFontLabel!
    @IBOutlet weak var feesTaxesLabel: ACLabel!
    @IBOutlet weak var feesButton: UIButton!
    
    @IBOutlet weak var taxesView: UIView!
    @IBOutlet weak var taxesValueLabel: TitleNoFontLabel!
    @IBOutlet weak var feeValueLabel: TitleNoFontLabel!
    
    @IBOutlet weak var paymentMethodView: UIView!
    @IBOutlet weak var paymentMethodIcon: CustomImageView!
    @IBOutlet weak var paymentMethodName: TitleNoFontLabel!
    
    @IBOutlet weak var totalToPayView: UIView!
    @IBOutlet weak var fiatTotalLabel: TitleNoFontLabel!
    @IBOutlet weak var cryptoTotalLabel: SubtitleLabel!
    
    @IBOutlet weak var bottomButtonView: UIView!
    @IBOutlet weak var bottomButton: BlueButton!
    
    @IBOutlet weak var viewBreakdownView: CellBackgroundView!
    @IBOutlet weak var viewBreakdounValueLabel: BlueLabel!
    @IBOutlet weak var viewBreakdownButtonTitle: ACLabel!
    
    @IBOutlet weak var orderIdView: UIView!
    @IBOutlet weak var orderIdLabel: TitleLabel!
    @IBOutlet weak var timeLabel: SubtitleLabel!
    
    @IBOutlet weak var spinner: JTMaterialSpinner!
    
    @IBOutlet weak var sendExactAmountView: UIView!
    @IBOutlet weak var sendExactCurrencylabel: BlueLabel!
    @IBOutlet weak var sendExactFiatLabel: SubtitleLabel!
    @IBOutlet weak var sendExactIcon: CustomImageView!
    
    @IBOutlet weak var showAddressView: UIView!
    @IBOutlet weak var arrowImageView: CustomImageView!
    
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLabel: BlueLabel!
    @IBOutlet weak var qrImage: CustomImageView!
    @IBOutlet weak var qrButton: UIButton!
    
    @IBOutlet weak var networkSpeedView: HomePageBackgroundView!
    @IBOutlet weak var networkSpeedLabel: TitleNoFontLabel!
    @IBOutlet weak var networkFeeLabel: SubtitleNoFontLabel!
    @IBOutlet weak var changeSpeedLabel: ACLabel!
    @IBOutlet weak var changeSpeedButton: UIButton!
    
    var stage: TopupStage = .selectOperator {
        didSet {
            updateTitle()
        }
    }
    var phone: String?
    var phoneWithoutFormat: String?
    var operators = [Operator]() {
        didSet {
            operatorsCollectionView.reloadData()
        }
    }
    var selectedOperator: Operator? {
        didSet {
            if let link = selectedOperator?.logo {
                operatorIcon.retrieveImgeFromLink(link)
            }
            operatorName.text = selectedOperator?.name
        }
    }
    var packages = [TopupPackage]() {
        didSet {
            packagesCollectionView.reloadData()
        }
    }
    var selectedPackage: TopupPackage? {
        didSet {
            if let currency = selectedPackage?.currency, let amount = selectedPackage?.amount, let fee = selectedPackage?.fee {
                currencyLabel.text = "(\(currency))"
                otherAmountCurrencyLabel.text = "(\(currency))"
                currencyLabel.isHidden = false
                fiatValueLabel.text = "\(amount) \(currency)"
                feeValueLabel.text = "\(fee) \(currency)"
            }
            if let amount = selectedPackage?.cryptoAmount, let currency = lookup?.cryptocurrency {
                rateLabel.isHidden = false
                rateLabel.text = "TOPUP_TOTAL_CRYPTO_LABEL".localized() + ": ~" + amount + " " + currency.uppercased()
                currencyValueLabel.text = "~ \(amount) \(currency.uppercased())"
            }
            continueButton.isEnabled = selectedPackage != nil
        }
    }
    var rate: Double?
    var selectedCurrency: TopupCurrency? {
        didSet {
            currencyName.text = selectedCurrency?.coin?.name
            paymentMethodName.text = selectedCurrency?.coin?.name
            currencyIcon.image = selectedCurrency?.coin?.image
            paymentMethodIcon.image = selectedCurrency?.coin?.image
            lookup(currency: selectedCurrency?.slug, operat: selectedOperator?.slug)
        }
    }
    var lookup: LookupResponse? {
        didSet {
            taxesValueLabel.text = lookup?.vat.info.isEmpty ?? true ? "0%" : lookup?.vat.info
            
            if let minValue = lookup?.customPrice?.min, let maxValue = lookup?.customPrice?.max,
                let currency = lookup?.customPrice?.currency {
                let minTitle = "\("MIN_AMOUNT".localized()) \(minValue) \(currency)"
                let maxTitle = "\("MAX_AMOUNT".localized()) \(maxValue) \(currency)"
                minButton.setTitle(minTitle, for: .normal)
                maxButton.setTitle(maxTitle, for: .normal)
            }
        }
    }
    var dialogView: DialogView!
    let walletDialogHeight = UIScreen.main.bounds.height - 112
    var topupResponse: TopupResponse? {
        didSet {
            if let topup = topupResponse {
                orderIdLabel.text = "\("TOPUP_ORDER_ID".localized()): \(topup.orderId)"
                
                sendExactCurrencylabel.text = "\(topup.coinAmount) \(topup.coinCurrency.uppercased())"
                sendExactFiatLabel.text = "\(topup.receiveAmount) \(topup.currency)"
                addressLabel.text = topup.deposit.address
                
                if let coin = try? TrustWalletCore.CoinType.getCoin(from: topup.coinCurrency) {
                    sendExactIcon.image = coin.image
                }
                time = expireTime ?? 0
                startTimer()
                spinner.beginRefreshing()
                
                qrView.topupResponse = topupResponse
                
                feeValueLabel.text = "\(topup.fee) USD"
            }
        }
    }
    
    var timer: Timer?
    var time = 0
    var expireTime: Int? {
        if let expire = topupResponse?.expire {
            return max(0, expire - Int(Date().timeIntervalSince1970))
        }
        return nil
    }
    
    var speedView: SpeedView!
    var qrView: QrView!
    let speedViewHeight: CGFloat = 360
    let qrViewHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    var otherAmount = "" {
        didSet {
            otherAmountTextField.text = otherAmount
            totalOtherAmount.text = "\("TOPUP_TOTAL_CRYPTO_LABEL".localized()): ~ \(otherAmountWithFee(amount: otherAmount))"
            feeValueLabel.text = otherAmountFee(amount: otherAmount)
            continueButton.isEnabled = !otherAmount.isEmpty
        }
    }
    
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPhoneView()
        lookup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupUI() {
        updateTitle()
        operatorsCollectionView.register(cellClass: OperatorCollectionViewCell.self)
        packagesCollectionView.register(cellClass: PackageCollectionViewCell.self)
        operatorIconContainer.layer.borderWidth = 1
        operatorIconContainer.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 0.2599999905).cgColor
        selectedCurrency = WalletManager.defaultTopupCurrency
        continueButton.isEnabled = false
        spinner.circleLayer.lineWidth = 2
        spinner.circleLayer.strokeColor = #colorLiteral(red: 0.03921568627, green: 0.5215686275, blue: 1, alpha: 1)
        
        setUpDialogView()
        
        speedView = SpeedView(frame: CGRect(x: 0, y: view.frame.maxY, width: view.frame.width, height: speedViewHeight + 30))
        speedView.mode = .speed
        speedView.delegate = self
        view.addSubview(speedView)
        
        qrView = QrView(frame: CGRect(x: 0, y: view.frame.maxY, width: view.frame.width, height: qrViewHeight + 30))
        qrView.delegate = self
        view.addSubview(qrView)
        
        email = ApplicationManager.referralEmail
        
        containerView.layer.cornerRadius = 18
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        otherAmountView.addGestureRecognizer(tap)
    }
    
    override func handleDismiss() {
        hideDialog()
        hideSpeedView()
        hideQrView()
    }
    
    fileprivate func setUpDialogView() {
        let frame = view.frame
        dialogView = DialogView(frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: walletDialogHeight + 30))
        dialogView.topupDelegate = self
        view.addSubview(dialogView)
    }
    
    func updateTitle() {
        stepsLabel.text = String(format: "TOPUP_STEP".localized(), stage.rawValue)
        stepNameLabel.text = stage.title
    }
    
    func setupPhoneView() {
        phoneLabel.text = phone
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func lookup(currency: String? = nil, operat: String? = nil) {
        guard var phone = phone else { return }
        phone = phone.replacingOccurrences(of: "-", with: " ")
        operatorsActivityIndicator.startAnimating()
        NetworkManager.lookupRequest(phone: phone, currency: currency, operat: operat) { (lookup, error) in
            DispatchQueue.main.async {
                self.operatorsActivityIndicator.stopAnimating()
                if let error = error {
                    self.showError(error)
                }
                if let lookup = lookup {
                    self.continueButton.isEnabled = true
                    self.rate = lookup.rate
                    self.lookup = lookup
                    self.selectedOperator = lookup.topupOperator
                    self.operators = lookup.availableOperators
                    self.packages = lookup.packages ?? []
                    self.selectedPackage = lookup.packages?.first
                }
            }
        }
    }
    
    func showDialog() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        dialogView.dialogType = .topup
        window.addSubview(dialogView)
        blackView.frame = window.frame
        
        dialogView.updateTextFieldBorder()
        
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
    
    func createTopup() {
        guard let email = ApplicationManager.referralEmail, !email.isEmpty else {
            return
        }
        guard let phone = phone,
            let currency = selectedCurrency?.slug,
            let operat = selectedOperator?.slug else { return }
        var amount = "0"
        if let packAmount = selectedPackage?.amount {
            amount = packAmount
        } else if !otherAmount.isEmpty {
            amount = otherAmount
        }
        bottomButton.startLoading()
        NetworkManager.createTopup(phone: phone, currency: currency, operat: operat, amount: amount, email: email) { [weak self] (response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.bottomButton.stopLoading()
                    self?.showError(error)
                }
                if let response = response {
                    self?.topupResponse = response
                    self?.prepareTransaction()
                    print("TOPUP: ", response)
                }
            }
        }
    }
    
    func prepareTransaction() {
        guard let currency = selectedCurrency,
            let wallet = WalletManager.wallet(currency: currency.sign),
            let address = topupResponse?.deposit.address,
            let amount = topupResponse?.coinAmount else { return }
        bottomButton.startLoading()
        //TO DO: dest tag, memo
        TransactionManager.shouldThrottleError = true
        TransactionManager.createTransaction(wallet: wallet, address: address, amount: amount, exchangeTag: topupResponse?.deposit.exchangeTag, destinationTag: topupResponse?.deposit.destinationTag, completion: { [weak self] (success) in
            DispatchQueue.main.async {
                self?.bottomButton.stopLoading()
                TransactionManager.transactionHeaders?.topupOrderId = self?.topupResponse?.orderId
                self?.updateSpeedInfo()
                self?.moveToPaymentStage(hideButton: !success)
            }
        })
    }
    
    func makePayment() {
        TransactionManager.submitTransaction(destinationTag: nil, exchangeTag: nil) { [weak self] (txId) in
            if txId != nil {
                self?.moveToSuccessScreen()
//                            self?.passToSuccessScreen(txId: txId)
            }
            self?.bottomButton.stopLoading()
        }
    }
    
    func moveToSuccessScreen() {
        if let vc = UIStoryboard.get(flow: .topUp).get(controller: .topupSucceededVC) as? TopupSucceededViewController {
            vc.topupResponse = topupResponse
            vc.phone = phone
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func editPhone(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func close(_ sender: Any) {
        goBack()
    }
    
    @IBAction func continueAction(_ sender: Any) {
        switch stage {
        case .selectOperator:
            moveToAmountStage()
        case .amount:
            moveToConfirmStage()
        default: break
        }
    }

    @IBAction func changeOperator(_ sender: Any) {
        moveToSelectOperatorStage()
    }
    
    @IBAction func changeCurrency(_ sender: Any) {
        showDialog()
    }
    @IBAction func minButtonAction(_ sender: Any) {
        otherAmount = "\(lookup?.customPrice?.min ?? 0)"
    }
    
    @IBAction func maxButtonAction(_ sender: Any) {
        otherAmount = "\(lookup?.customPrice?.max ?? 0)"
    }
    
    @IBAction func showTaxesAction(_ sender: Any) {
        feesTaxesLabel.text = taxesView.isHidden ? "HIDE".localized() : "TOPUP_FEE_TAXES".localized()
        taxesView.isHidden.toggle()
    }
    
    @IBAction func viewBreakdonnAction(_ sender: Any) {
        viewBreakdownButtonTitle.text = taxesView.isHidden ? "HIDE".localized() : "TOPUP_VIEW_BREAKDOWN".localized()
        taxesView.isHidden.toggle()
    }
    
    @IBAction func changeSendExactAmount(_ sender: Any) {
        moveToAmountStage()
    }
    
    @IBAction func createTopup(_ sender: Any) {
        if stage == .confirm {
            createTopup()
        } else if stage == .payment {
//            #if targetEnvironment(simulator)
//            moveToSuccessScreen()
//            #else
            makePayment()
//            #endif
        }
    }
    
    @IBAction func showAddressAction(_ sender: Any) {
        arrowImageView.image = addressView.isHidden ? #imageLiteral(resourceName: "chevron-up") : #imageLiteral(resourceName: "chevron-down")
        addressView.isHidden.toggle()
    }
    
    @IBAction func qrAction(_ sender: Any) {
        showQrView()
    }
    
    @IBAction func changeSpeedAction(_ sender: Any) {
        showSpeedView()
    }
    
    func moveToSelectOperatorStage() {
        stage = .selectOperator
        operatorsContainer.isHidden = false
        operatorView.isHidden = true
        packagesContainer.isHidden = true
        currencyView.isHidden = true
        selectedAmountView.isHidden = true
        receiveAmountView.isHidden = true
        paymentMethodView.isHidden = true
        totalToPayView.isHidden = true
        viewBreakdownView.isHidden = true
        orderIdView.isHidden = true
        sendExactAmountView.isHidden = true
        showAddressView.isHidden = true
        addressView.isHidden = true
        networkSpeedView.isHidden = true
        
        continueView.isHidden = false
        bottomButtonView.isHidden = true
        
        otherAmountTextField.text = ""
    }
    
    func moveToAmountStage() {
        stage = .amount
        operatorsContainer.isHidden = true
        selectedAmountView.isHidden = true
        receiveAmountView.isHidden = true
        paymentMethodView.isHidden = true
        totalToPayView.isHidden = true
        viewBreakdownView.isHidden = true
        orderIdView.isHidden = true
        sendExactAmountView.isHidden = true
        showAddressView.isHidden = true
        addressView.isHidden = true
        bottomButtonView.isHidden = true
        networkSpeedView.isHidden = true
        
        operatorView.isHidden = false
        packagesContainer.isHidden = false
        currencyView.isHidden = false
        continueView.isHidden = false
    }
    
    func moveToConfirmStage() {
        stage = .confirm
        packagesContainer.isHidden = true
        currencyView.isHidden = true
        continueView.isHidden = true
        viewBreakdownView.isHidden = true
        orderIdView.isHidden = true
        sendExactAmountView.isHidden = true
        showAddressView.isHidden = true
        addressView.isHidden = true
        networkSpeedView.isHidden = true
        
        selectedAmountView.isHidden = false
        receiveAmountView.isHidden = false
        paymentMethodView.isHidden = false
        totalToPayView.isHidden = false
        bottomButtonView.isHidden = false
        bottomButton.setTitle("TOPUP_CONTINUE_PAYMENT".localized(), for: .normal)
        
        if let package = selectedPackage {
            selectedAmountValue.text = "\(amountWithFee(package: package)) \(package.currency)"
            receiveAmountLabel.text = "\(package.amount) \(package.currency)"
            viewBreakdounValueLabel.text = "\(package.amount) \(package.currency)"
            fiatTotalLabel.text = "\(amountWithFee(package: package)) \(package.currency)"
            if let currency = lookup?.cryptocurrency.uppercased() {
                cryptoTotalLabel.text = "~\(totalCrypto(package: package)) \(currency)"
            }
        } else if !otherAmount.isEmpty, let currency = lookup?.customPrice?.currency {
            selectedAmountValue.text = "\("TOPUP_TOTAL_CRYPTO_LABEL".localized()): ~ \(otherAmountFee(amount: otherAmount))"
            receiveAmountLabel.text = "\(otherAmount) \(currency)"
            viewBreakdounValueLabel.text = "\(otherAmount) \(currency)"
            fiatTotalLabel.text = "\(otherAmountFee(amount: otherAmount))"
            if let cryptocurrency = lookup?.cryptocurrency.uppercased() {
                cryptoTotalLabel.text = ""// "~\(totalCrypto(package: package)) \(cryptocurrency)"
            }
        }
    }
    
    func moveToPaymentStage(hideButton: Bool = false) {
        stage = .payment
        viewBreakdownView.isHidden = false
        orderIdView.isHidden = false
        sendExactAmountView.isHidden = false
        showAddressView.isHidden = false
        networkSpeedView.isHidden = false
        
        selectedAmountView.isHidden = true
        receiveAmountView.isHidden = true
        paymentMethodView.isHidden = true
        totalToPayView.isHidden = true
        taxesView.isHidden = true
        
        let qrDisable = topupResponse?.qr.isEmpty ?? true
        qrImage.isHidden = qrDisable
        qrButton.isEnabled = !qrDisable
        
        if let currency = selectedCurrency {
            let title = String(format: "TOPUP_PAY_WITH".localized(), currency.slug.capitalized)
            bottomButton.setTitle(title, for: .normal)
            bottomButtonView.isHidden = currency.localId == 0
        }
        if hideButton {
            bottomButtonView.isHidden = true
            networkSpeedView.isHidden = true
        }
    }
    
    func amountWithFee(package: TopupPackage) -> String {
        if let amount = BDouble(package.amount), let fee = BDouble(package.fee) {
            let receivedAmount = amount + fee
            return receivedAmount.rounded().description
        }
        return "0"
    }
    
    func otherAmountFee(amount: String) -> String {
        if let dAmount = Double(amount),
            let feePercent = lookup?.customPrice?.feePercent,
            let dPercent = Double(feePercent),
            let minFee = lookup?.customPrice?.minFee,
            let currency = lookup?.customPrice?.currency {
            let fee = dAmount * (dPercent / 100)
            
            let feeString = String(format: "%.2f", max(minFee, fee))
            
            return "\(feeString) \(currency)"
        }
        return ""
    }
    
    func otherAmountWithFee(amount: String) -> String {
        if let dAmount = Double(amount),
            let feePercent = lookup?.customPrice?.feePercent,
            let dPercent = Double(feePercent),
            let minFee = lookup?.customPrice?.minFee,
            let currency = lookup?.customPrice?.currency {
            var fee = dAmount * (dPercent / 100)
            fee = max(minFee, fee)
            let total = dAmount + fee
            let totalString = String(format: "%.2f", total)
            
            return "\(totalString) \(currency)"
        }
        return ""
    }
    
    func totalCrypto(package: TopupPackage) -> String {
        if let amount = BDouble(package.cryptoAmount), let fee = BDouble(package.cryptoFee) {
            let totalAmount = amount + fee
            if let afterDecimalPoint = totalAmount.description.components(separatedBy: "/").last {
                let afterPointCount = afterDecimalPoint.count - 1
                let totalString = totalAmount.decimalExpansion(precisionAfterDecimalPoint: afterPointCount)
                return totalString
            }
        }
        return "0"
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            if self.time > 0 {
                self.time -= 1
                var timerText = ""
                let minutes = self.time/60
                let seconds = self.time - (minutes * 60)
                let secondsString = String(format: "%02d", seconds)
                timerText = "\(minutes):\(secondsString)"
                self.timeLabel.text = timerText
            } else {
                self.timeLabel.text = "0:00"
                self.deactivateTimer()
            }
        })
    }
    
    func deactivateTimer() {
        if timer?.isValid ?? false {
            spinner.endRefreshing()
            timer?.invalidate()
            showExpireScreen()
        }
    }
    
    func showExpireScreen() {
        if let vc = UIStoryboard.get(flow: .topUp).get(controller: .topupExpiredVC) as? TopupExpiredViewController {
            vc.orderId = topupResponse?.orderId
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showSpeedView() {
        speedView.metas = TransactionManager.transactionResponse?.meta.sorted(by: { $0.value > $1.value })
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        window.addSubview(speedView)
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.speedView.transform = CGAffineTransform(translationX: 0, y: -self.speedViewHeight)
        }
    }
    
    func hideSpeedView() {
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.speedView.transform = .identity
        }
    }
    
    func showQrView() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        window.addSubview(qrView)
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.qrView.transform = CGAffineTransform(translationX: 0, y: -self.qrViewHeight)
        }
    }
    
    func hideQrView() {
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.qrView.transform = .identity
        }
    }
    
    func updateSpeedInfo() {
        guard let currency = TransactionManager.transactionHeaders?.currency else { return }
        if let fee = TransactionManager.feeForSpeed(TransactionManager.speed), let total = TransactionManager.totalForSpeed(TransactionManager.speed) {
            TransactionManager.transactionHeaders.fee = fee
            currencyLabel.text = currency.currency.uppercased()
            networkSpeedLabel.text = TransactionManager.speed.localizedKey.localized()
            networkSpeedLabel.isHidden = false
        } else {
            networkSpeedLabel.isHidden = true
            if let meta = TransactionManager.transactionResponse?.meta.first {
                TransactionManager.transactionHeaders.fee = meta.fee
            }
        }
        
        networkFeeLabel.text = "\("NETWORK_FEE".localized()): \(TransactionManager.transactionHeaders.fee) \(currency.currency.uppercased())"
    }
}

extension TopUpViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == operatorsCollectionView {
            return operators.count
        }
        if (lookup?.customPrice?.max ?? 0) > 0 {
            return packages.count + 1
        } else {
            return packages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == operatorsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId(OperatorCollectionViewCell.self), for: indexPath) as! OperatorCollectionViewCell
            let topupOperator = operators[indexPath.item]
            cell.topupOperator = topupOperator
            cell.setSelected(topupOperator.slug == selectedOperator?.slug)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId(PackageCollectionViewCell.self), for: indexPath) as! PackageCollectionViewCell
        if indexPath.item < packages.count {
            let package = packages[indexPath.item]
            cell.package = package
            cell.setSelected(selectedPackage?.amount == package.amount)
        } else {
            cell.setupCell(other: true)
            cell.setSelected(false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == operatorsCollectionView {
            return CGSize(width: 100, height: 150)
        }
        return CGSize(width: 100, height: 57)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if collectionView == operatorsCollectionView {
            let topupOperator = operators[indexPath.item]
            selectedOperator = topupOperator
            lookup(currency: selectedCurrency?.slug, operat: topupOperator.slug)
            operatorsCollectionView.reloadData()
        } else if collectionView == packagesCollectionView {
            if indexPath.item < packages.count {
                let package = packages[indexPath.item]
                selectedPackage = package
                packagesCollectionView.reloadData()
            } else if !packages.isEmpty {
                selectedPackage = nil
                otherAmountView.isHidden = false
            }
        }
    }
}

enum TopupStage: String {
    case selectOperator = "1"
    case amount = "2"
    case confirm = "3"
    case payment = "4"
    
    var title: String {
        switch self {
        case .selectOperator:
            return "TOPUP_OPERATOR_TITLE".localized()
        case .amount:
            return "TOPUP_AMOUNT_TITLE".localized()
        case .confirm:
            return "TOPUP_CONFIRM_TITLE".localized()
        case .payment:
            return "TOPUP_PAYMENT".localized()
        }
    }
}

extension TopUpViewController: TopupDelegate {
    func selectCurrency(_ currency: TopupCurrency) {
        hideDialog()
        rateLabel.text = ""
        currencyValueLabel.text = ""
        selectedCurrency = currency
    }
}

extension TopUpViewController: SpeedViewDelegate, QrViewDelegate {
    func addressSelected(_ address: String) {
    }
    
    func speedSelected() {
        updateSpeedInfo()
        hideSpeedView()
    }
    
    func closeView() {
        hideQrView()
    }
    
    
}

extension TopUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            otherAmount = text.replacingCharacters(in: textRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return false
    }
}
