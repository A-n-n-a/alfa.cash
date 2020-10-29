//
//  CheckboxTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 15.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class CheckboxTableViewCell: UITableViewCell {

    @IBOutlet weak var languageLabel: TitleLabel!
    @IBOutlet weak var checkmarkIcon: UIImageView!
    
    var language: LanguageManager.AppLanguage! {
        didSet {
            languageLabel.text = language.localizedName
        }
    }
    
    var selectedLanguage: LanguageManager.AppLanguage! {
        didSet {
            checkmarkIcon.isHidden = selectedLanguage != language
            languageLabel.alpha = selectedLanguage == language ? 1 : 0.4
        }
    }
    
    var fiat: Fiat! {
        didSet {
            languageLabel.text = fiat.rawValue.uppercased()
        }
    }
        
    var selectedFiat: Fiat! {
        didSet {
            checkmarkIcon.isHidden = selectedFiat != fiat
        }
    }
    
    var theme: ThemeManager.ThemeType! {
        didSet {
            languageLabel.setText(theme.name)
        }
    }
    
    var selectedTheme: ThemeManager.ThemeType! {
        didSet {
            checkmarkIcon.isHidden = selectedTheme != theme
        }
    }
    
    var security: SecurityType! {
        didSet {
            switch security {
            case .faceId:
                languageLabel.setText("LOGIN_METHOD_FACE_ID")
            case .touchId:
                languageLabel.setText("LOGIN_METHOD_TOUCH_ID")
            case .passcode:
                languageLabel.setText("PASSCODE")
            default:
                break
            }
        }
    }
    
    func setUpSecuritySelection() {
        switch security {
        case .faceId, .touchId:
            checkmarkIcon.isHidden = !UserDefaults.standard.bool(forKey: Constants.Main.udBiometryEnabled)
        case .passcode:
            checkmarkIcon.isHidden = false
        default:
            break
        }
    }
    
    var lockType: LockType! {
        didSet {
            languageLabel.text = lockType.title
            
            switch lockType {
            case .access:
                checkmarkIcon.isHidden = false // UserDefaults.standard.bool(forKey: Constants.Main.udLoginSecurityDisabled)
            default:
                checkmarkIcon.isHidden = !UserDefaults.standard.bool(forKey: Constants.Main.udTransactionSecurityEnabled)
            }
        }
    }
}
