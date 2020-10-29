//
//  Constants.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 15.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    
    struct Main {
        
        static let udPasscode = "udPasscode"
        static let udUsername = "udUsername"
        static let udMnemonic = "udMnemonic"
        static let udMnemonicString = "udMnemonicString"
        static let udBiometryEnabled = "udBiometryEnabled"
        static let udTransactionSecurityEnabled = "udTransactionSecurityEnabled"
        static let udFirstRun = "udFirstRun"
        static let udToken = "udToken"
        static let udRecentAddresses = "udRecentAddresses"
        static let udColorTheme = "ColorTheme"
        static let udReferralPopupWasShown = "udReferralPopupWasShown"
        static let udReferralId = "udReferralId"
        static let udLastPhone = "udLastPhone"
    }
    
    struct DateFormats {
        static let transactionTime = "MMM dd, yyyy HH:mm"
        static let chartDay = "MMM dd, yyyy"
        static let chartTime = "HH:mm"
        static let referralFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        static let referralSwipeFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    struct QRCode {
        static let sharingScale: CGFloat = 512
        static let defaultScale: CGFloat = 176
        static let inputCorrectionLevel = "M"
    }
    
    struct Email {
        static let appAlfa = "app@alfa.cash"
    }
    
    struct Link {
        static let terms = "https://wallet.alfa.cash/terms"
        static let policy = "https://wallet.alfa.cash/privacy-policy"
        static let referral = "https://wallet.alfa.cash/referral-program"
    }
}
