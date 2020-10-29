//
//  RecoveryPhraseViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 24.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import CryptoKit

class RecoveryPhraseViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var iCloudButton: BlueButton!
    
    var mnemonicString = ""
    var mnemonicWords = [String]() {
        didSet {
            collectionView.reloadData()
            mnemonicString = mnemonicWords.joined(separator:" ")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(cellClass: MnemonicCollectionViewCell.self)
        
        showMnemonica()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        setUpNavBar(title: "RECOVERY_PHRASE")
        
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudBackupSuccess), name: NSNotification.Name.iCloudBackupSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudBackupError(notification:)), name: NSNotification.Name.iCloudBackupError, object: nil)
    }
    
    func showMnemonica() {
        if let mnemonica = KeychainWrapper.standart.getMnemonic() {
            mnemonicWords = mnemonica
        }
    }
    @IBAction func backupToIcloud(_ sender: Any) {
        showAlertWithTextField()
    }
    
    func saveMnemonicToIcloud(fileName: String, password: String) {
        activityIndicator.startAnimating()
        iCloudButton.setEnable(false)
        do {
            try iCloudHelper().startBackup(fileName: fileName, password: password)
            DispatchQueue.main.asyncAfter(deadline: .now() +  0.4) {
                self.iCloudBackupSuccess()
            }
        } catch {
            activityIndicator.stopAnimating()
            iCloudButton.setEnable(true)
            showError(error)
        }
    }
    
    func showAlertWithTextField() {
        
        let alert = UIAlertController(title: "ICLOUD_ENTER_FILE_NAME".localized(), message: "", preferredStyle: UIAlertController.Style.alert )
        
        let save = UIAlertAction(title: "SAVE".localized(), style: .default) { (alertAction) in
            if let nameTextField = alert.textFields?.first,
                let passwordTextField = alert.textFields?.last {
            
                if let name = nameTextField.text,
                    !name.isEmpty,
                    let password = passwordTextField.text,
                    !password.isEmpty {
                    self.saveMnemonicToIcloud(fileName: name, password: password)
                }
            }
        }

        alert.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "ICLOUD_ENTER_FILE_NAME".localized()
        }
        
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "ENTER_PASSWORD".localized()
        }

        alert.addAction(save)
        let cancel = UIAlertAction(title: "CANCEL".localized(), style: .cancel) { (alertAction) in }
        alert.addAction(cancel)

        self.present(alert, animated:true, completion: nil)

    }
    
    @IBAction func copyMnemonic(_ sender: Any) {
        UIPasteboard.general.string = mnemonicString
        let okAction = UIAlertAction(title: "OK".localized().localized(), style: .cancel, handler: nil)
        self.showAlert(title: nil, message: "MNEMONIC_COPIED_TO_CLIPBOARD".localized(), actions: [okAction])
    }
    
    @objc func iCloudBackupSuccess() {
        iCloudButton.setEnable(true)
        activityIndicator.stopAnimating()
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil)
        self.showAlert(title: nil, message: "MNEMONIC_SAVED_TO_CLOUD".localized(), actions: [okAction])
    }
    
    @objc func iCloudBackupError(notification: Notification) {
        iCloudButton.setEnable(true)
        activityIndicator.stopAnimating()
        if let error = notification.userInfo?["error"] as? Error {
            showError(error)
        }
    }
}

extension RecoveryPhraseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mnemonicWords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId(MnemonicCollectionViewCell.self), for: indexPath) as! MnemonicCollectionViewCell
        cell.word = mnemonicWords[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 10
        let height = collectionView.frame.height / 4 - 10
        let size = CGSize(width: width, height: height)
        return size
    }
}

extension RecoveryPhraseViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string != "."
    }
}
