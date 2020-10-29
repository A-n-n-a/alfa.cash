//
//  PinView.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 18.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import FlagPhoneNumber

protocol DialogViewNavigationDelegate {
    func showDialog(_ show: Bool)
    func goToReceive(wallet: Wallet)
    func goToSend(wallet: Wallet)
}

protocol DialogViewExchangeDelegate {
    func selectWallet(_ wallet: Wallet, type: ExchangeType)
}

protocol TopupDelegate {
    func selectCurrency(_ currency: TopupCurrency)
}

protocol CountriesDelegate {
    func countrySelected(_ country: FPNCountry)
}

class DialogView: UIView {
    
    @IBOutlet weak var titleLabel: ACLabel!
    @IBOutlet weak var subtitleLabel: ACLabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textField: ACTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pinButton: UIButton!
    
    //=========================================================
    // MARK: - Initialization
    //=========================================================
    
    var navigationDelegate: DialogViewNavigationDelegate?
    var exchangeDelegate: DialogViewExchangeDelegate?
    var countryDelegate: CountriesDelegate?
    var topupDelegate: TopupDelegate?
    
    var wallets = [Wallet]() {
        didSet {
            tableView.reloadData()
        }
    }
    var currencies = [TopupCurrency]() {
        didSet {
            tableView.reloadData()
        }
    }
    var dialogType: DialogType = .pin {
        didSet {
            pinButton.isHidden = true
            switch dialogType {
            case .pin:
                titleLabel.setText("SELECT_TO_PIN_TO_YOUR_WALLET")
                subtitleLabel.isHidden = true
            case .receive:
                titleLabel.setText("RECEIVE")
                subtitleLabel.isHidden = false
            case .send, .eosActivation:
                titleLabel.setText("SEND")
                subtitleLabel.isHidden = false
            case .selectExchange:
                let title = exchangeType == .from ? "SEND" : "RECEIVE"
                titleLabel.setText(title)
                subtitleLabel.isHidden = false
            case .countries:
                titleLabel.setText("POPUP_COUNTRIES_TITLE")
                subtitleLabel.isHidden = true
            case .topup:
                titleLabel.setText("TOPUP_LABEL_SELECT_PAYMENT_METHOD")
                subtitleLabel.isHidden = true
            }
            updateWallets()
        }
    }
    
    private var query = "" {
        didSet {
            if !query.isEmpty {
                if dialogType == .countries {
                    searchCountries()
                } else {
                    searchWallet()
                }
            } else {
                if dialogType == .countries {
                    countries = countriesToFilter
                } else {
                    wallets = dialogType == .pin ? WalletManager.unpinnedWallets : WalletManager.pinnedWallets
                }
            }
        }
    }
    
    var walletsToPin = [Wallet]() {
        didSet {
            pinButton.isHidden = walletsToPin.isEmpty
        }
    }
    
    var exchangeType = ExchangeType.from
    var countries: [FPNCountry] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var countriesToFilter: [FPNCountry] = []
   
    override init(frame: CGRect) {
       super.init(frame: frame)
       
       setup()
    }
   
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       
       setup()
    }
   
    private func setup() {
        let nib =  UINib(nibName: "DialogView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
        
        if let lang = ApplicationManager.profile?.language.rawValue {
            print(lang)
            let locale = Locale(identifier: lang)
            let repo = FPNCountryRepository(locale: locale)
            countries = repo.countries
            countriesToFilter = repo.countries
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(cellClass: PinTableViewCell.self)
        tableView.register(cellClass: CountryCodeTableViewCell.self)
        
        textField.delegate = self
        textField.setUpRightView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateWallets), name: NSNotification.Name.walletsUpdate, object: nil)
        
        updateWallets()
    }
    
    func resetCellsSelection() {
        if let visibleCells = tableView.visibleCells as? [PinTableViewCell] {
            visibleCells.forEach({$0.selectedToPin = false})
        }
    }
    
    @objc func updateWallets() {
        wallets = getWalletsArray()
    }
    
    func updateTextFieldBorder() {
        textField.layer.borderColor = ThemeManager.currentTheme.associatedObject.textFieldBorderColor.cgColor
    }
    
    func getWalletsArray() -> [Wallet] {
        var wallets = [Wallet]()
        switch dialogType {
        case .pin:
            wallets = WalletManager.unpinnedWallets
        case .selectExchange:
            wallets = WalletManager.pinnedWallets.filter({ (wallet) -> Bool in
                wallet.coin != .tron
//                wallet.coin == .bitcoin || wallet.coin == .litecoin || wallet.coin == .bitcoinCash || wallet.coin == .ethereum
            })
        case.eosActivation:
            wallets = WalletManager.pinnedWallets.filter({ $0.coin != .eos })
        case .topup:
            currencies = WalletManager.topupCurrencies
        default:
            wallets = WalletManager.pinnedWallets
        }
        return wallets
    }
    
    @IBAction func pinAction(_ sender: Any) {
        pinWallets()
    }
    
    func pinWallets() {
        
        activityIndicator.startAnimating()
        var errorMessage: String?
        let updateGroup = DispatchGroup()
                
        DispatchQueue.concurrentPerform(iterations: walletsToPin.count) { counterIndex in
            let index = Int(counterIndex)
            let wallet = walletsToPin[index]
            
            updateGroup.enter()
            
            NetworkManager.pinWallet(id: wallet.id, pin: true) { (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        errorMessage = error.error ?? error.message
                    }
                    updateGroup.leave()
                }
            }
        }
        updateGroup.notify(queue: DispatchQueue.main) {
            if let errorMessage = errorMessage,
                let topVC = UIApplication.topViewController() as? BaseViewController {
                self.activityIndicator.stopAnimating()
                topVC.showError(errorMessage)
            } else {
                self.walletsToPin = []
                self.getWallets()
            }
        }
    }
    
    func getWallets() {
        NetworkManager.getWallets { [weak self] (wallets, error) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                if let wallets = wallets {
                    WalletManager.wallets = wallets
                    self?.navigationDelegate?.showDialog(false)
                }
                if let error = error,
                    let topVC = UIApplication.topViewController() as? BaseViewController {
                    
                    topVC.showError(error)
                }
            }
        }
    }
    
    func searchWallet() {
        let walletsToSort = getWalletsArray()
        wallets = walletsToSort.filter { (wallet) -> Bool in
            let walletName = wallet.title.lowercased()
            let currency = wallet.currency.lowercased()
            return walletName.contains(query.lowercased()) || currency.contains(query.lowercased())
        }
    }
    
    func searchCountries() {
        
        countries = countriesToFilter.filter { (country) -> Bool in
            let countryName = country.name.lowercased()
            
            return countryName.contains(query.lowercased())
        }
    }
}

extension DialogView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dialogType == .topup {
            return currencies.count
        }
        if dialogType == .countries {
            return countries.count
        }
        if section == 0 {
            return wallets.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dialogType == .countries {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CountryCodeTableViewCell.self), for: indexPath) as! CountryCodeTableViewCell
            cell.country = countries[indexPath.row]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PinTableViewCell.self), for: indexPath) as! PinTableViewCell
        cell.delegate = self
        if dialogType == .topup {
            cell.currency = currencies[indexPath.row]
        } else {
            cell.wallet = wallets[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dialogType == .countries {
            return 53
        }
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch dialogType {
        case .pin:
            if let cell = tableView.cellForRow(at: indexPath) as? PinTableViewCell {
                cell.selectedToPin.toggle()
            }
        case .receive:
            let wallet = wallets[indexPath.row]
            navigationDelegate?.showDialog(false)
            navigationDelegate?.goToReceive(wallet: wallet)
        case .send:
            let wallet = wallets[indexPath.row]
            navigationDelegate?.showDialog(false)
            navigationDelegate?.goToSend(wallet: wallet)
        case .selectExchange, .eosActivation:
            let wallet = wallets[indexPath.row]
            exchangeDelegate?.selectWallet(wallet, type: exchangeType)
        case .countries:
            let country = countries[indexPath.row]
            countryDelegate?.countrySelected(country)
            countries = countriesToFilter
        case .topup:
            let currency = currencies[indexPath.row]
            topupDelegate?.selectCurrency(currency)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return "YOUR_COINS".headerThemedViewWithTitle()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dialogType == .countries {
            return 0
        }
        return 45
    }
}

extension DialogView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
        if let text = textField.text, let textRange = Range(range, in: text) {
            query = text.replacingCharacters(in: textRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("")
    }
}

extension DialogView: PinTableViewCellDelegate {
    
    func appendWalletToPin(_ wallet: Wallet) {
        walletsToPin.append(wallet)
    }
    
    func removeWalletToPin(id: Int) {
        for (index, wallet) in walletsToPin.enumerated() {
            if wallet.id == id {
                walletsToPin.remove(at: index)
            }
        }
    }
}



enum DialogType {
    case pin
    case receive
    case send
    case selectExchange
    case eosActivation
    case countries
    case topup
}

enum ExchangeType {
    case from
    case to
}
