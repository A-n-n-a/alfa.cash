//
//  SettingsViewModel.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 28.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

class SettingsViewModel {
    
    var sections: [Sections] = [.referals, .profile, .security, .alfaCashAccount, .localSettings, .theme, .about]
    let securitySection: [SettingsItem] = [.recoveryPhrase, .appLock]
    let settingsSection: [SettingsItem] = [.currency, .language]//, .notifications]
    let aboutSection: [SettingsItem] = [.version, .legal, /*.faq,*/ .report]
    
    func settingsModel(item: SettingsItem) -> SettingsItemModel? {
        switch item {
        case .recoveryPhrase:
            return SettingsItemModel(title: "RECOVERY_PHRASE")
        case .appLock:
            return SettingsItemModel(title: "APP_LOCK")
        case .currency:
            //TODO: currencies support
            return SettingsItemModel(title: "LOCAL_CURRENCY", subtitle: "SET_UP_THE_BASE_CURRENCY", value: FiatManager.currentFiat.rawValue.uppercased())
        case .language:
            let lang = LanguageManager.currentLanguage.localizedName
            return SettingsItemModel(title: "LANGUAGE", value: lang)
        case .notifications:
            return SettingsItemModel(title: "NOTIFICATIONS", subtitle: "CONTROL_YOUR_NOTIFICATIONS")
        case .theme:
            let theme = ThemeManager.currentTheme
            return SettingsItemModel(title: theme.name)
        case .version:
            if let version = Bundle.main.version, let build = Bundle.main.build {
                let version = "\(version).\(build)"
                return SettingsItemModel(title: "VERSION", value: version, valueBlack: false)
            }
            return SettingsItemModel(title: "VERSION")
        case .legal:
            return SettingsItemModel(title: "LEGAL")
        case .faq:
            return SettingsItemModel(title: "SETTINGS_FAQ")
        case .report:
            return SettingsItemModel(title: "REPORT_A_PROBLEM")
        case .referal:
            return SettingsItemModel(title: "SETTINGS_REFER_EARN", subtitle: "RECEIVE_20", image: #imageLiteral(resourceName: "giftWithWhiteContainer"))
        case .account:
            return SettingsItemModel(title: "CONNECT_TO_ALFACASH", subtitle: "ACCESS_DISCOUNT_AFFILIATE_PROGRAMS", image: #imageLiteral(resourceName: "alfacashLogo"))
        default:
            return nil
        }
    }
    
    func settingsModel(title: String) -> SettingsItemModel {
        return SettingsItemModel(title: title)
    }
    
    enum Sections {
        case referals
        case profile
        case security
        case alfaCashAccount
        case localSettings
        case theme
        case about
    }

    enum SettingsItem {
        case username
        case recoveryPhrase
        case appLock
        case currency
        case language
        case emptyWallets
        case notifications
        case theme
        case version
        case legal
        case faq
        case report
        case account
        case referal
    }

}
