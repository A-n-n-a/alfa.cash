//
//  SecuritySettingsViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 22.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class SecuritySettingsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: SettingsTableView!
    
    var viewModel = SettingsViewModel()
    var accesses: [LockType] = [.access, .transaction]

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar(title: "APP_LOCK")
        tableView.register(cellClass: CheckboxSettingsTableViewCell.self)
        tableView.register(cellClass: SettingsBaseTableViewCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

extension SecuritySettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let settingsCell = tableView.dequeueReusableCell(withIdentifier: cellId(SettingsBaseTableViewCell.self)) as! SettingsBaseTableViewCell
            let model = viewModel.settingsModel(item: .appLock)
            model?.value = UserDefaults.standard.bool(forKey: Constants.Main.udBiometryEnabled) ? BiometryManager.biometryType.rawValue : "PASSCODE".localized()
            settingsCell.model = model
            return settingsCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(CheckboxSettingsTableViewCell.self)) as! CheckboxSettingsTableViewCell
            
            cell.lockType = accesses[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 {
            if let vc = UIStoryboard.get(flow: .settings).get(controller: .appLock) as? AppLockViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if indexPath.row == 0 {
//                var loginSecurityDisabled = UserDefaults.standard.bool(forKey: Constants.Main.udLoginSecurityDisabled)
//                let transactionSecurityEnabled = UserDefaults.standard.bool(forKey: Constants.Main.udTransactionSecurityEnabled)
//                if loginSecurityDisabled || transactionSecurityEnabled {
//                    loginSecurityDisabled.toggle()
//                    UserDefaults.standard.set(loginSecurityDisabled, forKey: Constants.Main.udLoginSecurityDisabled)
//                }
            } else {
                var transactionSecurityEnabled = UserDefaults.standard.bool(forKey: Constants.Main.udTransactionSecurityEnabled)
//                let loginSecurityDisabled = UserDefaults.standard.bool(forKey: Constants.Main.udLoginSecurityDisabled)
//                if !loginSecurityDisabled || !transactionSecurityEnabled {
                    transactionSecurityEnabled.toggle()
                    UserDefaults.standard.set(transactionSecurityEnabled, forKey: Constants.Main.udTransactionSecurityEnabled)
//                }
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return "PROFILE".headerThemedViewWithTitle()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
}


enum LockType {
    case access
    case transaction
    
    var title: String {
        switch self {
        case .access:
            return "REQUIRE_FOR_APP_ACCESS".localized()
        case .transaction:
            return "REQUIRE_FOR_TRANSACTIONS".localized()
        }
        
    }
}
