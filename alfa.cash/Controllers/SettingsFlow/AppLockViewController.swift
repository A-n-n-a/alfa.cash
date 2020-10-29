//
//  AppLockViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 21.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class AppLockViewController: BaseViewController {
    
    @IBOutlet weak var tableView: SettingsTableView!
    
    var securities: [SecurityType] = [.passcode] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar(title: "APP_LOCK")
        tableView.register(cellClass: CheckboxSettingsTableViewCell.self)

        switch BiometryManager.biometryType {
        case .touchID:
            securities.append(.touchId)
        case .faceID:
            securities.append(.faceId)
        default: break
        }
    }
}

extension AppLockViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return securities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(CheckboxSettingsTableViewCell.self)) as! CheckboxSettingsTableViewCell
        
        cell.security = securities[indexPath.row]
        cell.setUpSecuritySelection()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row == 1 {
            if let vc = UIStoryboard.get(flow: .options).get(controller: .passcode) as? PasscodeViewController {
                vc.modalPresentationStyle = .fullScreen
                vc.mode = .transaction
                vc.delegate = self
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return "MANAGE_YOUR_LOCK_METHOD".headerThemedViewWithTitle()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
}

extension AppLockViewController: PassCodeDelegate {
    func passCodeDidMatch() {
        var biometryEnabled = UserDefaults.standard.bool(forKey: Constants.Main.udBiometryEnabled)
        biometryEnabled.toggle()
        UserDefaults.standard.set(biometryEnabled, forKey: Constants.Main.udBiometryEnabled)
        tableView.reloadData()
    }
}
