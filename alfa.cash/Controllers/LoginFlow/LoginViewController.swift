//
//  LoginViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 06.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import BitcoinKit
import TrustWalletCore

class LoginViewController: BaseViewController {

    @IBOutlet weak var textView: ACTextView!
    @IBOutlet weak var nextButton: BlueButton!
    @IBOutlet weak var iCloudButton: NoBorderButton!
    
    var helper = iCloudHelper()
    var mnemonicsView: SpeedView!
    let mnemonicsViewHeight: CGFloat = 360
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpWhiteNavBarForLogin(title: "RECOVERY_PHRASE")
        
        iCloudButton.isHidden = helper.getMnemonicFiles().isEmpty
        nextButton.setEnable(false)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupUI() {
        let frame = view.frame
        mnemonicsView = SpeedView(frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: mnemonicsViewHeight + 30))
        mnemonicsView.mode = .iCloud
        mnemonicsView.delegate = self
        view.addSubview(mnemonicsView)
    }
    
    func showDialog() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        window.addSubview(mnemonicsView)
        blackView.frame = window.frame
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.mnemonicsView.transform = CGAffineTransform(translationX: 0, y: -self.mnemonicsViewHeight)
        }
    }
    
    func hideDialog() {
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.mnemonicsView.transform = .identity
        }
    }
    
    override func handleDismiss() {
        hideDialog()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        nextButton.setEnable(false)
        var textViewText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        textViewText = textViewText.removeExtraSpaces()
        let mnemonic = textViewText.components(separatedBy: " ")
        do {
            try WalletManager.checkMnemonic(mnemonic)
            if let authData = try WalletManager.getLoginAuthData(mnemonic: mnemonic) {
                login(authData: authData)
            }
        } catch {
            nextButton.setEnable(true)
            showError(ACError(message: "LOGIN_MNEMONIC_MISMATCH".localized()))
        }
    }
    @IBAction func retrieveMnemonicFromiCloud(_ sender: Any) {
        let mnemonicFiles = helper.getMnemonicFiles()
        mnemonicsView.files = mnemonicFiles
        showDialog()
    }
    
    func login(authData: AuthData) {
        NetworkManager.login(authData: authData) { [weak self] (registration, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.nextButton.setEnable(true)
                    self?.showError(error)
                }
                if let registration = registration {
                    let token = registration.auth.token
                    #if DEBUG
                    print("TOKEN: ", token)
                    #endif
                    KeychainWrapper.standart.set(value: token, forKey: Constants.Main.udToken)
                    ApplicationManager.profile = registration.user
                    FirebaseManager.shared.subscribeTo(id: registration.user.id)
                    self?.moveToPassCodeScreen()
                }
            }
        }
    }
    
    func moveToPassCodeScreen() {
        if let vc = UIStoryboard.get(flow: .options).get(controller: .security) as? SecurityViewController {
            vc.login = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension LoginViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let mnemonic = textView.text, let textRange = Range(range, in: mnemonic) {
            let query = mnemonic.replacingCharacters(in: textRange, with: text).trimmingCharacters(in: .whitespacesAndNewlines)
            nextButton.setEnable(!query.isEmpty)
        }
        
        if text == "\n" {
            self.view.endEditing(true)
        }
        return true
    }
}

extension LoginViewController: SpeedViewDelegate {
    func speedSelected() {
        
    }
    
    func addressSelected(_ address: String) {
        
        showAlertWithTextField(fileName: address)
    }
    
    func showAlertWithTextField(fileName: String) {
        
        let alert = UIAlertController(title: "ENTER_PASSWORD".localized(), message: "", preferredStyle: UIAlertController.Style.alert )
        
        let save = UIAlertAction(title: "OK".localized(), style: .default) { (alertAction) in
            if let textField = alert.textFields?.first {
                do {
                if let password = textField.text,
                    !password.isEmpty, let mnemonic = try self.helper.retrieveMnemonicFromiCloud(fileName: fileName, password: password) {
                    
                    self.textView.text = mnemonic
                    self.nextButton.setEnable(true)
                    
                    self.hideDialog()
                }
                } catch {
                    let err = ACError(message: "WRONG_PASSWORD".localized())
                    self.showError(err)
                }
            }
        }
        
        alert.addTextField { (textField) in

            textField.placeholder = "ENTER_PASSWORD".localized()
        }
        
        alert.addAction(save)
        let cancel = UIAlertAction(title: "CANCEL".localized(), style: .cancel) { (alertAction) in }
        alert.addAction(cancel)
        
        self.present(alert, animated:true, completion: nil)
    }
}
