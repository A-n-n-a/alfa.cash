//
//  UsernameViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 17.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import RxSwift

class UsernameViewController: BaseViewController, ChildViewControllerDelegate {
    
    @IBOutlet weak var nextButton: BlueButton!
    @IBOutlet weak var usernameTextField: UsernameTextField!
    @IBOutlet weak var checkingLabel: SubtitleLabel!
    @IBOutlet weak var checkmark: UIImageView!
    
    var delegate: ContainerViewControllerDelegate?
    var username = ""

    var timer: Timer?
    var searchText = ""
    var usernameError: String? = nil
    var usernameState: UsernameState! {
        didSet {
            nextButton.setEnable(usernameState == .available)
            checkmark.isHidden = true
            switch usernameState {
            case .checking:
                checkingLabel.text = "CHECKING".localized()
            case .available:
                checkingLabel.text = "AVAILABLE".localized()
                checkmark.isHidden = false
            case .exists:
                checkingLabel.text = "WARNING_USERNAME_EXISTS".localized()
            case .trouble:
                checkingLabel.text = usernameError
            default:
                checkingLabel.isHidden = true
            }
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameState = .checking

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let username = ApplicationManager.tempUsername {
            usernameTextField.text = username
            self.username = username
        }
        nextButton.setEnable(ApplicationManager.tempUsername != nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        ApplicationManager.tempUsername = username
        delegate?.nextButtonAction(skip:  false)
    }
    
    @IBAction func skipAction(_ sender: Any) {
        delegate?.nextButtonAction(skip: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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

}

extension UsernameViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if timer?.isValid ?? false {
            timer?.invalidate()
        }
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let query = text.replacingCharacters(in: textRange, with: string)
            if !query.isNameValid() {
                return false
            } else if query.count > 3 {
                checkingLabel.isHidden = true
                checkmark.isHidden = true
                self.username = query
            } else {
                usernameState = UsernameState.none
                
                return true
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { (_) in
                if self.searchText != query {
                    self.checkUsername(query)
                }
                self.searchText = query
            })
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

enum UsernameState {
    case checking
    case available
    case exists
    case trouble
    case none
}
