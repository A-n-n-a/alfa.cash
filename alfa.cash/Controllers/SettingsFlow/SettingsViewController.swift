//
//  SettingsViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 27.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController, UsernameViewDelegate {
    
    @IBOutlet weak var tableView: SettingsTableView!
    
    var viewModel = SettingsViewModel()
    var usernameView: UsernameView!
    let usernameViewHeignt: CGFloat = 300
    var bottomConstraint: NSLayoutConstraint?
    var bottomConnectViewConstraint: NSLayoutConstraint?
    
    let connectView = ConnectView(frame: CGRect(x: 12, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width - 24, height: 284))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cellClass: UsernameTableViewCell.self)
        tableView.register(cellClass: SettingsBaseTableViewCell.self)
        tableView.register(cellClass: SettingsIconTableViewCell.self)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        tableView.reloadData()
        
        setUpNavBar(title: "SETTINGS")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if ApplicationManager.profile?.connectedToAlfacash ?? true, viewModel.sections[3] == .alfaCashAccount {
            viewModel.sections.remove(at: 3) //.alfacasAccount
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI() {
        let frame = view.frame
        usernameView = UsernameView(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: usernameViewHeignt + 30))
        usernameView.delegate = self
        connectView.delegate = self
    }
    
    func showUsernameView() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        blackView.addSubview(usernameView)
        usernameView.translatesAutoresizingMaskIntoConstraints = false
        usernameView.leadingAnchor.constraint(equalTo: blackView.leadingAnchor).isActive = true
        usernameView.trailingAnchor.constraint(equalTo: blackView.trailingAnchor).isActive = true
        bottomConstraint = usernameView.bottomAnchor.constraint(equalTo: blackView.bottomAnchor, constant: 30)
        bottomConstraint?.isActive = true
        usernameView.heightAnchor.constraint(equalToConstant: 330).isActive = true
        blackView.frame = window.frame
        
        usernameView.checkingLabel.isHidden = true
        usernameView.checkmark.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 1
            self.blackView.layoutIfNeeded()
        }
    }
    
    func hideUsernameView() {
        tableView.reloadData()
        usernameView.usernameTextField.resignFirstResponder()
        bottomConstraint?.constant = 330
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.blackView.layoutIfNeeded()
        }
    }
    
    override func handleDismiss() {
        hideUsernameView()
        hideConnectView()
    }
    
    func handleLocalSettingsSelection(item: SettingsViewModel.SettingsItem) {
        switch item {
        case .username:
            if let username = ApplicationManager.profile?.login, !username.isEmpty, let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 1)) as? UsernameTableViewCell {
                cell.copyName()
            } else {
                showUsernameView()
            }
        case .language:
            if let vc = UIStoryboard.get(flow: .settings).get(controller: .languages) as? LanguagesViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .currency:
            if let vc = UIStoryboard.get(flow: .settings).get(controller: .currencyVC) as? CurrencyViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .theme:
            if let vc = UIStoryboard.get(flow: .settings).get(controller: .themeVC) as? ThemeViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .legal:
            if let vc = UIStoryboard.get(flow: .settings).get(controller: .legalSettings) as? LegalSettingsViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .recoveryPhrase:
            if let vc = UIStoryboard.get(flow: .options).get(controller: .passcode) as? PasscodeViewController {
                vc.modalPresentationStyle = .fullScreen
                vc.mode = .transaction
                vc.delegate = self
                present(vc, animated: true, completion: nil)
            }
        case .appLock:
            if let vc = UIStoryboard.get(flow: .settings).get(controller: .securitySettingsVC) as? SecuritySettingsViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .faq:
            if let vc = UIStoryboard.get(flow: .settings).get(controller: .faqVC) as? FaqViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .report:
            let email = Constants.Email.appAlfa
            if let url = URL(string: "mailto:\(email)") {
                UIApplication.shared.open(url)
            }
        case .referal:
            if ApplicationManager.profile?.connectedToAlfacash ?? false, let referralVC = UIStoryboard.get(flow: .referral).instantiateInitialViewController() as? ReferralViewController {
                navigationController?.pushViewController(referralVC, animated: true)
            } else {
                showConnectView()
            }
        case .account:
            connectToAlfacash()
        default:
            break
        }
    }
    
    @objc func logoutAction() {
        if let vc = UIStoryboard.get(flow: .loginFlow).get(controller: .logout) as? LogoutViewController {
            vc.modalPresentationStyle = .fullScreen
            
            self.navigationController?.view.applyModalAnimation()
            self.navigationController?.pushViewController(vc, animated: false)
            
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint?.constant = -(keyboardSize.height - 30)
            UIView.animate(withDuration: 0.4) {
                self.blackView.layoutIfNeeded()
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraint?.constant = 30
        UIView.animate(withDuration: 0.4) {
            self.blackView.layoutIfNeeded()
        }
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
        connectView.heightAnchor.constraint(equalToConstant: 284).isActive = true
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
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = viewModel.sections[section]
        switch section {
        case .profile, .referals, .alfaCashAccount, .theme: return 1
        case .security: return viewModel.securitySection.count
        case .localSettings: return viewModel.settingsSection.count
        case .about: return viewModel.aboutSection.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.sections[indexPath.section]
        let settingsCell = tableView.dequeueReusableCell(withIdentifier: cellId(SettingsBaseTableViewCell.self)) as! SettingsBaseTableViewCell
        var item: SettingsViewModel.SettingsItem?
        switch section {
        case .profile:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(UsernameTableViewCell.self)) as! UsernameTableViewCell
            if let username = ApplicationManager.profile?.login, !username.isEmpty {
                cell.username = "@\(username)"
            } else {
                cell.username = nil
            }
            return cell
        case .security:
            item = viewModel.securitySection[indexPath.row]
        case .localSettings:
            item = viewModel.settingsSection[indexPath.row]
        case .about:
            item = viewModel.aboutSection[indexPath.row]
        case .theme:
            item = .theme
        case .alfaCashAccount, .referals:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(SettingsIconTableViewCell.self)) as! SettingsIconTableViewCell
            let item: SettingsViewModel.SettingsItem = section == .alfaCashAccount ? .account : .referal
            cell.model = viewModel.settingsModel(item: item)
            return cell
        }
        if let item = item {
            let model = viewModel.settingsModel(item: item)
            settingsCell.model = model
        }
        return settingsCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = viewModel.sections[indexPath.section]
        
        switch section {
        case .referals: return 80
        case .profile, .alfaCashAccount, .localSettings: return 75
        case .security, .theme, .about: return 56
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var text = ""
        let section = viewModel.sections[section]
        
        switch section {
        case .referals:
            text = ""
        case .profile:
            text = "PROFILE"
        case .security:
            text = "SECURITY"
        case .alfaCashAccount:
            text = "ALFACASH_ACCOUNT"
        case .localSettings:
            text = "LOCAL_SETTINGS"
        case .theme:
            text = "SKINS"
        case .about:
            text = "ABOUT_ALFACASH_WALLET"
        }

        return text.headerThemedViewWithTitle()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setHighlighted(false, animated: false)
        
        let section = viewModel.sections[indexPath.section]
        
        var item: SettingsViewModel.SettingsItem?
        switch section {
            case .referals:
                item = .referal
            case .profile:
                item = .username
            case .security:
                item = viewModel.securitySection[indexPath.row]
            case .alfaCashAccount:
                item = .account
            case .localSettings:
                item = viewModel.settingsSection[indexPath.row]
            case .theme:
                item = .theme
            case .about:
                item = viewModel.aboutSection[indexPath.row]
        default:
            break
        }
        if let item = item {
            handleLocalSettingsSelection(item: item)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == viewModel.sections.count - 1 {
            let footer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 52))
            let button = NoBorderThemedButton(frame: footer.frame)
            button.localizedKey = "SIGN_OUT_OF_CURRENT_SEEDPHRASE"
            button.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.setTitleColor(UIColor.kErrorColor, for: .normal)
            footer.addSubview(button)
            return footer
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == viewModel.sections.count - 1 {
            return 52
        }
        return 0
    }
}

extension SettingsViewController: ConnectViewDelegate {
    func connectToAlfa() {
        connectToAlfacash()
    }
}

extension SettingsViewController: PassCodeDelegate {
    func passCodeDidMatch() {
            if let vc = UIStoryboard.get(flow: .settings).get(controller: .recoveryPhrase) as? RecoveryPhraseViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
    }
}
