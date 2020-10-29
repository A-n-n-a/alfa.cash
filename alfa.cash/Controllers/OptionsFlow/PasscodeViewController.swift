//
//  PasscodeViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 21.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol PassCodeDelegate {
    func passCodeDidMatch()
}

class PasscodeViewController: BaseViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var descriptionLabel: HeaderLabel!
    @IBOutlet weak var biometryButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var passCode = ""
    private var passCodeFirstVersion = ""
    private var passCodeSecondVersion = ""
    var mode: PassCodeMode = .setup
    private let biometryManager = BiometryManager()
    private var biometryEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Constants.Main.udBiometryEnabled)
    }
    var hideBackButton = false
    var delegate: PassCodeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var title = ""
        switch mode {
        case .setup:
            title = "SETUP_PASSCODE"
        case .login, .transaction:
            title = "PASSCODE"
        }
        setUpBlueNavBar(title: title, hideBackButton: hideBackButton || mode == .login)
        
        if mode != .setup {
            if biometryEnabled {

                biometryButton.setImage(BiometryManager.biometryType.image, for: .normal)
                descriptionLabel.text = String(format: "UNLOCK_WITH_PIN_PLACEHOLDER".localized(), BiometryManager.biometryType.rawValue)
                
                handleBiometry(biometryButton.self)
            } else {
                descriptionLabel.isHidden = true
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func typingPasscode(_ sender: UIButton) {
        
        descriptionLabel.isHidden = mode != .setup
        
        if sender.tag == 11 { // delete
            if passCode.isEmpty {
                return
            }
            passCode.removeLast()
        } else if sender.tag == 10 { //0
            addNumberToPassCode("0")
        } else {
            addNumberToPassCode("\(sender.tag)")
        }
        updateCirclesView()
    }
    
    @IBAction func handleBiometry(_ sender: UIButton) {
        guard mode != .setup else { return }
        biometryManager.authorizeUsingBiometry(success: { [weak self] in
            DispatchQueue.main.async {
                if self?.mode == .transaction {
                    self?.dismiss(animated: true) {
                        self?.delegate?.passCodeDidMatch()
                    }
                } else {
                    self?.moveToHomePage()
                }
            }
        }, failure: nil)
    }
    
    func updateCirclesView() {
        guard let circles = stackView?.subviews else { return }
        for (index, circle) in circles.enumerated() {
            guard let circle = circle as? PasscodeCircle else { return }
            if passCode.count > index {
                circle.setFilled()
            } else {
                circle.setEmpty()
            }
        }
    }
    
    func addNumberToPassCode(_ number: String) {
        guard passCode.count < 6 else { return }
        passCode.append(number)
        if passCode.count == 6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.mode == .setup ? self.setUpPassCode() : self.handlePassCodeMatch()
            }
        }
    }
    
    func setUpPassCode() {
        if self.passCodeFirstVersion.isEmpty {
            self.passCodeFirstVersion = self.passCode
            self.passCode = ""
            self.updateCirclesView()
            self.descriptionLabel.setText("REPEAT_YOUR_PASSCODE")
        } else {
            if self.passCode == self.passCodeFirstVersion {
                self.passCodeSecondVersion = self.passCode
                
                if KeychainWrapper().set(value: self.passCode, forKey: Constants.Main.udPasscode) {
                    if hideBackButton {
                        moveToHomePage()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    EventLogger.log(issue: "Error saving user data into KC", severity: .error)
                }
            } else {
                self.passCode = ""
                self.passCodeFirstVersion = ""
                self.updateCirclesView()
                self.descriptionLabel.setText("ERROR_PASSCODE_NOT_MATCH")
            }
        }
    }
    
    func handlePassCodeMatch() {
        if let passcodeFromKeychain = KeychainWrapper.standart.value(forKey: Constants.Main.udPasscode),  passcodeFromKeychain == passCode {
            if mode == .transaction {
                dismiss(animated: true) {
                    self.delegate?.passCodeDidMatch()
                }
            } else {
                moveToHomePage()
            }
        } else {
            self.passCode = ""
            self.updateCirclesView()
            self.descriptionLabel.isHidden = false
            self.descriptionLabel.setText("ERROR_PASSCODE_NOT_MATCH")
        }
    }
}

enum PassCodeMode {
    case setup
    case login
    case transaction
}
