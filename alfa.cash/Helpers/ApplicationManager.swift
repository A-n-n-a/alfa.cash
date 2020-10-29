//
//  ApplicationManager.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 16.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import RxSwift

class ApplicationManager {
    
    static let disposeBag = DisposeBag()
    
    static var tempUsername: String?
    static var tempLanguage: LanguageManager.AppLanguage?
    
    static var profile: Profile?
    static var needUpdateHomePage: Bool = false
    static var needCheckNotifications = false
    static var ratesNeedUpdate = false
    static var referralUrl: URL?
    static var referralInfo: ReferralInfo?
    static var referralEmail: String?
    
    static func clearCache() {
        UserDefaults.standard.removeObject(forKey: Constants.Main.udToken)
        UserDefaults.standard.removeObject(forKey: Constants.Main.udTransactionSecurityEnabled)
        UserDefaults.standard.removeObject(forKey: Constants.Main.udBiometryEnabled)
        UserDefaults.standard.removeObject(forKey: Constants.Main.udReferralPopupWasShown)
        UserDefaults.standard.removeObject(forKey: Constants.Main.udLastPhone)
        ThemeManager.shared.saveTheme(.day)
        ThemeManager.shared.themeService.switch(.day)
        ApplicationManager.referralEmail = nil
    }
}
