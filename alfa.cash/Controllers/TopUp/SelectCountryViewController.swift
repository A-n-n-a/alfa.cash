//
//  SelectCountryViewController.swift
//  alfa.cash
//
//  Created by Anna on 7/28/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import FlagPhoneNumber

class SelectCountryViewController: BaseViewController {

    @IBOutlet weak var textField: FPNTextField!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewWidth: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topupButton: BlueButton!
    @IBOutlet weak var lastPhoneStack: UIStackView!
    @IBOutlet weak var lastPhoneLabel: ACLabel!
    
    var selectedCountry: FPNCountry? {
        didSet {
            textField.selectedCountry = selectedCountry
            flagImage.image = selectedCountry?.flag
        }
    }
    
    var dialogView: DialogView!
    let walletDialogHeight = UIScreen.main.bounds.height - 112
    var currencies = [TopupCurrency]() {
        didSet {
            setCollectionViewSize()
            collectionView.reloadData()
        }
    }
    
    let connectView = ConnectWithEmailView(frame: CGRect(x: 12, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width - 24, height: 396))
    var bottomConstraint: NSLayoutConstraint?
    var bottomConnectViewConstraint: NSLayoutConstraint?
    var lastPhoneView: LastPhoneView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let countries = FPNCountryRepository().countries
        var defaultCountryCode: FPNCountryCode = .US
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String,
        let fpnCountryCode = FPNCountryCode(rawValue: countryCode) {
            defaultCountryCode = fpnCountryCode
            
        }
        
        for country in countries {
            if country.code == defaultCountryCode {
                selectedCountry = country
            }
        }
        textField.hasPhoneNumberExample = true
        textField.delegate = self
        
        setupUI()
        getCurrencies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupUI() {
        let frame = view.frame
        dialogView = DialogView(frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: walletDialogHeight + 30))
        dialogView.countryDelegate = self
        view.addSubview(dialogView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
        
        collectionView.register(cellClass: TopupCurrencyCollectionViewCell.self)
        
        topupButton.setEnable(false)
        
        connectView.delegate = self
        
        #if targetEnvironment(simulator)
        if selectedCountry?.code == .UA {
            textField.text = "63 239 0228"
        } else {
            textField.text = "423 249 7777"
        }
        topupButton.setEnable(true)
        #endif
        
        textField.textColor = ThemeManager.currentTheme == .day ? .black : .white
        
        setupLastPhone()
    }
    
    func setupLastPhone() {
        if let lastPhone = UserDefaults.standard.value(forKey: Constants.Main.udLastPhone) as? String {
            lastPhoneStack.isHidden = false
            lastPhoneLabel.text = lastPhone
            
            lastPhoneView = LastPhoneView(phone: lastPhone)
            lastPhoneView?.delegate = self
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(showLastPhoneView))
            lastPhoneStack.addGestureRecognizer(tap)
        }
    }
    
    @objc func showLastPhoneView() {
        guard let window = window, let lastPhoneView = lastPhoneView else { return }
        updateBlackView()
        window.addSubview(blackView)
        window.addSubview(lastPhoneView)
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.lastPhoneView?.transform = CGAffineTransform(translationX: 0, y: -222)
        }
    }
    
    func hideLastPhoneView() {
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.lastPhoneView?.transform = .identity
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func getCurrencies() {
        NetworkManager.getTopupCurrencies { [weak self] (currencies, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let currencies = currencies {
                    self?.currencies = currencies
                    WalletManager.topupCurrencies = currencies
                }
            }
        }
    }
    
    func setCollectionViewSize() {
        let maxWidth: CGFloat = UIScreen.main.bounds.width - 60
        let itemWidth: CGFloat = 39
        let spacing: CGFloat = 11
        let spacingWidth: CGFloat = spacing * CGFloat((currencies.count - 1))
        let itemsWidth = itemWidth * CGFloat(currencies.count) + spacingWidth
        collectionViewHeight.constant = itemsWidth < maxWidth ? 39 : 89
        collectionViewWidth.constant = itemsWidth < maxWidth ? itemsWidth : maxWidth
        view.layoutIfNeeded()
    }
    
    func showDialog() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        dialogView.dialogType = .countries
        window.addSubview(dialogView)
        blackView.frame = window.frame
        
        dialogView.updateTextFieldBorder()
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
        hideConnectView()
        hideLastPhoneView()
    }
    
    func showConnectView() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        blackView.addSubview(connectView)
        connectView.translatesAutoresizingMaskIntoConstraints = false
        connectView.leadingAnchor.constraint(equalTo: blackView.leadingAnchor, constant: 12).isActive = true
        blackView.trailingAnchor.constraint(equalTo: connectView.trailingAnchor, constant: 12).isActive = true
        bottomConnectViewConstraint = blackView.bottomAnchor.constraint(equalTo: connectView.bottomAnchor, constant: 30)
        bottomConnectViewConstraint?.isActive = true
        connectView.heightAnchor.constraint(equalToConstant: 396).isActive = true
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 1
            self.blackView.layoutIfNeeded()
        }
    }
    
    func hideConnectView() {
        bottomConnectViewConstraint?.constant = -400
        UIView.animate(withDuration: 0.3, animations: {
            self.blackView.alpha = 0
            self.blackView.layoutIfNeeded()
        }) { (_) in
            self.connectView.removeFromSuperview()
        }
    }
    
    @IBAction func close(_ sender: Any) {
        goBack()
    }
    
    @IBAction func selectCountry(_ sender: Any) {
        showDialog()
    }
    
    @IBAction func topup(_ sender: Any) {
        if let code = selectedCountry?.phoneCode, let phone = textField.text {
            moveToTopup(phone: code + " " + phone)
        }
    }
    
    func moveToTopup(phone: String?) {
        if (ApplicationManager.profile?.connectedToAlfacash ?? false) || ApplicationManager.referralEmail != nil {
            if let vc = UIStoryboard.get(flow: .topUp).get(controller: .topUpVC) as? TopUpViewController {
                if let phone = phone {
                    vc.phone = phone
                }
                vc.phoneWithoutFormat =  textField.getRawPhoneNumber()
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            view.endEditing(true)
            showConnectView()
        }
    }
}

extension SelectCountryViewController: FPNTextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        topupButton.setEnable(textField.getFormattedPhoneNumber(format: .National) != nil)
    }
    
    func fpnDisplayCountryList() {
        
    }
}

extension SelectCountryViewController: CountriesDelegate {
    func countrySelected(_ country: FPNCountry) {
        hideDialog()
        selectedCountry = country
        textField.text = ""
    }
}

extension SelectCountryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId(TopupCurrencyCollectionViewCell.self), for: indexPath) as! TopupCurrencyCollectionViewCell
        cell.currency = currencies[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 39, height: 39)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
}

extension SelectCountryViewController: LastPhoneDelegate {
    func useLastPhone() {
        hideLastPhoneView()
        textField.text = UserDefaults.standard.string(forKey: Constants.Main.udLastPhone)
        moveToTopup(phone: UserDefaults.standard.string(forKey: Constants.Main.udLastPhone))
    }
    
    func cancelAction() {
        hideLastPhoneView()
    }
}

extension SelectCountryViewController: ConnectWithEmailViewDelegate {
    
    func connectToAlfa() {
        hideConnectView()
        clearCookies()
        if let url = ApplicationManager.referralUrl {
            WebViewManager.shared.openURL(url, from: self, title: "CONNECT_TO_ALFACASH")
        }
    }
    
    func emailAction() {
        hideConnectView()
        requestEmail()
    }
    
    func requestEmail() {
        
        let alert = UIAlertController(title: "TOPUP_EMAIL_PLACEHOLDER".localized(), message: "", preferredStyle: UIAlertController.Style.alert )
        
        let save = UIAlertAction(title: "OK".localized(), style: .default) { (alertAction) in
            if let textField = alert.textFields?.first {
                if let email = textField.text {
                    ApplicationManager.referralEmail = email
                    if let code = self.selectedCountry?.phoneCode, let phone = self.textField.text {
                        self.moveToTopup(phone: code + " " + phone)
                    }
                }
            }
        }
        
        alert.addTextField { (textField) in

            textField.placeholder = "TOPUP_EMAIL_PLACEHOLDER".localized()
        }
        
        alert.addAction(save)
        let cancel = UIAlertAction(title: "CANCEL".localized(), style: .cancel) { (alertAction) in }
        alert.addAction(cancel)
        
        self.present(alert, animated:true, completion: nil)
    }
}
