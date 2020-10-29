//
//  SecurityViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 17.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class SecurityViewController: BaseViewController, ChildViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: BlueButton!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var securities: [SecurityType] = [.passcode] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var delegate: ContainerViewControllerDelegate?
    private let biometryManager = BiometryManager()
    
    var login = false
   
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        
        setUpBlueNavBar(title: "SECURITY")
   }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupSecurityOptions), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        setupSecurityOptions()
        updateButton()
        navigationController?.setNavigationBarHidden(!login, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
   func setUpUI() {
       tableView.register(cellClass: BiometryTableViewCell.self)
   }
    
   @objc func setupSecurityOptions() {
        tableViewHeight.constant = 128
        switch BiometryManager.biometryType {
        case .touchID:
            securities.append(.touchId)
        case .faceID:
            securities.insert(.faceId, at: 0)
        default:
            tableViewHeight.constant = 64
        }
        
        view.layoutIfNeeded()
    }
    
    func updateButton() {
        let passcodeExists = KeychainWrapper.standart.value(forKey: Constants.Main.udPasscode) != nil
        nextButton.setEnable(passcodeExists)
    }
    
    func startLoadingAnimation() {
        nextButton.startLoading()
    }
    
    func stopLoadingAnimation() {
        nextButton.stopLoading()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if login {
            moveToHomePage()
        } else {
            delegate?.nextButtonAction(skip: false)
        }
    }
}

extension SecurityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return securities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(BiometryTableViewCell.self)) as! BiometryTableViewCell
        cell.securityType = securities[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let securityType = securities[indexPath.row]
        if securityType == .passcode {
            showPasscodeSettings()
        } else {
            biometryManager.authorizeUsingBiometry(success: { [weak self] in
                // success
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: Constants.Main.udBiometryEnabled)
                    if KeychainWrapper.standart.value(forKey: Constants.Main.udPasscode) != nil {
                        self?.updateButton()
                    } else {
                        self?.showPasscodeSettings()
                    }
                }
            }) { (_, requiresToReset, isUserFallback) in
                if requiresToReset { // deny
                    UserDefaults.standard.set(false, forKey: Constants.Main.udBiometryEnabled)
                }
                
                if isUserFallback { //allow
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: Constants.Main.udBiometryEnabled)
                    }
                }
            }
        }
    }
    
    private func showPasscodeSettings() {
        DispatchQueue.main.async {
            if let vc = UIStoryboard.get(flow: .options).get(controller: .passcode) as? PasscodeViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


enum SecurityType {
    case faceId
    case passcode
    case touchId
}
