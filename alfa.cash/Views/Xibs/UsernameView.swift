//
//  UsernameView.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 07.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol UsernameViewDelegate {
    func hideUsernameView()
}

class UsernameView: UIView {
    
    
    @IBOutlet weak var copyLabel: ACLabel!
    @IBOutlet weak var nextButton: BlueButton!
    @IBOutlet weak var usernameTextField: ACTextField!
    @IBOutlet weak var checkingLabel: ACLabel!
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var delegate: UsernameViewDelegate?
    
    var timer: Timer?
    var username = ""
    var searchText = ""
    var usernameError: String? = nil
    var usernameState: UsernameState! {
        didSet {
            nextButton.setEnable(usernameState == .available)
            checkmark.isHidden = usernameState != .available
            switch usernameState {
            case .checking:
                checkingLabel.text = "CHECKING".localized()
            case .available:
                checkingLabel.text = "AVAILABLE".localized()
            case .exists:
                checkingLabel.text = "WARNING_USERNAME_EXISTS".localized()
            default:
                checkingLabel.text = usernameError
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        let nib =  UINib(nibName: "UsernameView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipe.direction = .down
        self.addGestureRecognizer(swipe)
        
        usernameTextField.delegate = self
        nextButton.setEnable(false)
        usernameTextField.text = ApplicationManager.profile?.login
        usernameTextField.inputAccessoryView = UIView(frame: CGRect.zero)
    }
    
    @objc func swipeAction() {
        delegate?.hideUsernameView()
    }
    
    func checkUsername(_ username: String) {
        checkingLabel.isHidden = false
        usernameState = .checking
        NetworkManager.isUsernameExists(username) { [weak self] (success, error) in
            if error != nil {
                self?.usernameError = error?.error
                self?.usernameState = .trouble
            } else {
                self?.usernameState = success ?? false ? .available : .exists
            }
        }
    }
    
    func saveUsername() {
        activityIndicator.startAnimating()
        if var profileCopy = ApplicationManager.profile {
            profileCopy.login = username
            NetworkManager.updateProfile(profileCopy) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    if success {
                        self?.getProfile()
                    }
                }
            }
        }
    }
    
    func getProfile() {
        NetworkManager.getProfile { [weak self] (profile, error) in
            DispatchQueue.main.async {
                if let profile = profile {
                    ApplicationManager.profile = profile
                    ApplicationManager.needUpdateHomePage = true
                    self?.delegate?.hideUsernameView()
                }
            }
        }
    }
    
    @IBAction func copyAction(_ sender: Any) {
        if let username = ApplicationManager.profile?.login {
            UIPasteboard.general.string = username
            copyLabel.textColor = .kButtonColor
        }
        
    }
    
    @IBAction func confirm(_ sender: Any) {
        saveUsername()
    }
}

extension UsernameView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if timer?.isValid ?? false {
            timer?.invalidate()
        }
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let query = text.replacingCharacters(in: textRange, with: string)
            let trimmedUsername = query.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedUsername.isNameValid() {
                return false
            } else if trimmedUsername.count > 3 {
                checkingLabel.isHidden = true
                self.username = trimmedUsername
            } else {
                usernameState = UsernameState.none
                return true
            }
            
            guard string != " " else { return true}
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { (_) in
                if self.searchText != trimmedUsername {
                    self.checkUsername(trimmedUsername)
                }
                self.searchText = trimmedUsername
            })
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        return true
    }
}
