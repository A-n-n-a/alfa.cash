//
//  CompleteSendViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 25.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import BitcoinKit
import TrustWalletCore
import BigInt
import TrustSDK

class CompleteSendViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addressTextField: ACTextField!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var sendButton: BlueButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var speedButtonLabel: UILabel!
    
    var address = ""
    var speedView: SpeedView!
    let speedViewHeight: CGFloat = 360
    var destinationTag: Int?
    var exchangeTag: String?
    
    private let biometryManager = BiometryManager()
    private var biometryEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Constants.Main.udBiometryEnabled)
    }
    private var transactionSecurityEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Constants.Main.udTransactionSecurityEnabled)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpTransactionsNavBar(title: "SEND_CRYPTO".localized())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        WalletManager.selectedSpeed = .medium
    }
    
    func setUpUI() {
            
        tableView.register(cellClass: CoinTableViewCell.self)
        tableView.register(cellClass: AmountTableViewCell.self)
        
        containerView.layer.borderColor = ThemeManager.currentTheme.associatedObject.textFieldBorderColor.cgColor
        containerView.layer.borderWidth = 2
        containerView.backgroundColor = ThemeManager.currentTheme.associatedObject.textfieldBackgroundColor
        
        updateSpeedInfo()
        
        addressTextField.text = address
        
        if TransactionManager.transactionResponse?.prioritySupport ?? false && !TransactionManager.speedButtonShouldHide {
            let frame = view.frame
            speedView = SpeedView(frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: speedViewHeight + 30))
            speedView.mode = .speed
            speedView.delegate = self
            speedView.metas = TransactionManager.transactionResponse?.meta.sorted(by: { $0.value > $1.value })
            view.addSubview(speedView)
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
    
    func updateSpeedInfo() {
        let currency = TransactionManager.transactionHeaders.currency
        if let fee = TransactionManager.feeForSpeed(TransactionManager.speed), let total = TransactionManager.totalForSpeed(TransactionManager.speed) {
            TransactionManager.transactionHeaders.fee = fee
            totalLabel.text = total
            currencyLabel.text = currency?.currency.uppercased()
            speedLabel.text = TransactionManager.speed.localizedKey.localized()
            speedLabel.isHidden = false
        } else {
            speedLabel.isHidden = true
            if let meta = TransactionManager.transactionResponse?.meta.first {
                TransactionManager.transactionHeaders.fee = meta.fee
            }
        }
        
        if let currency = currency?.currency.uppercased() {
            feesLabel.text = "\("NETWORK_FEE".localized()): \(TransactionManager.transactionHeaders.fee) \(currency)"
        }
    }
    
    @IBAction func changeSpeed(_ sender: Any) {
        showDialog()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if transactionSecurityEnabled {
            if biometryEnabled {
                biometryManager.authorizeUsingBiometry(success: { [weak self] in
                    DispatchQueue.main.async {
                        self?.submitTransaction()
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
            submitTransaction()
        }
    }
    
    func submitTransaction() {
        sendButton.startLoading()
        TransactionManager.submitTransaction(destinationTag: destinationTag, exchangeTag: exchangeTag) { [weak self] (txId) in
            if let txId = txId {
                self?.passToSuccessScreen(txId: txId)
            }
            self?.sendButton.stopLoading()
        }
    }
    
    func passToSuccessScreen(txId: String) {
        if let homeVC = navigationController?.viewControllers.first as? HomePageViewController, let sendSuccessfullyVC = UIStoryboard.get(flow: .sendFlow).get(controller: .sendSuccessfullyVC) as? SendSuccessfullyViewController {
            sendSuccessfullyVC.txId = txId
            sendSuccessfullyVC.currency = TransactionManager.transactionHeaders.currency 
            sendSuccessfullyVC.amount = TransactionManager.transactionHeaders.amount
            sendSuccessfullyVC.speed = TransactionManager.speed
            sendSuccessfullyVC.fee = TransactionManager.transactionHeaders.fee
            sendSuccessfullyVC.address = address
            WalletManager.appendRecentAddress(address)
            navigationController?.setViewControllers([homeVC, sendSuccessfullyVC], animated: true)
        }
    }
    
    func showDialog() {
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
    
    func hideDialog() {
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.speedView.transform = .identity
        }
    }
    
    override func handleDismiss() {
        hideDialog()
    }
}

extension CompleteSendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wallet = TransactionManager.transactionHeaders.wallet
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(CoinTableViewCell.self)) as! CoinTableViewCell
            cell.wallet = wallet
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(AmountTableViewCell.self)) as! AmountTableViewCell
            cell.currency = wallet.coin
            cell.amount = TransactionManager.transactionHeaders.amount
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 85
        }
        return 90
    }
}

enum Speed: String {
    case slow
    case medium = "regular"
    case fast
    
    var localizedKey: String {
        switch self {
            
        case .fast: return "FAST_NETWORK_SPEED"
        case .medium: return "MEDIUM_NETWORK_SPEED"
        case .slow: return "SLOW_NETWORK_SPEED"
        }
    }
}

extension CompleteSendViewController: SpeedViewDelegate {
    func speedSelected() {
        updateSpeedInfo()
        handleDismiss()
    }
    
    func addressSelected(_ address: String) {

    }
}

extension CompleteSendViewController: PassCodeDelegate {
    func passCodeDidMatch() {
        submitTransaction()
    }
}
