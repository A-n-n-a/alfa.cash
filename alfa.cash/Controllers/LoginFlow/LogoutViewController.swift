//
//  LogoutViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 10.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class LogoutViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        
        navigationController?.view.applyModalAnimation(dissmiss: true)
        navigationController?.popViewController(animated: false)
    }

    @IBAction func backupAction(_ sender: Any) {
        if let vc = UIStoryboard.get(flow: .settings).get(controller: .recoveryPhrase) as? RecoveryPhraseViewController {

            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        if let userId = ApplicationManager.profile?.id {
            FirebaseManager.shared.unsubscribeFrom(id: userId)
        }
        KeychainWrapper.standart.clearKeychain()
        ApplicationManager.clearCache()
        TransactionManager.transactions = []
        WalletManager.wallets = []
        Presenter.showOnboarding()
    }
}
