//
//  StoryboardHelper.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

// Storyboard Files
enum StoryboardFlow: String {
    case onboarding = "OnboardingFlow"
    case setLanguage = "SetLanguageFlow"
    case options = "OptionsFlow"
    case settings = "SettingsFlow"
    case home = "HomePageFlow"
    case sendFlow = "SendFlow"
    case exchangeFlow = "ExchangeFlow"
    case receiveFlow = "ReceiveFlow"
    case loginFlow = "LoginFlow"
    case coinPage = "CoinPage"
    case referral = "Referral"
    case topUp = "TopUpFlow"
}

// ViewController Storyboard ID's
enum StoryboardControllerID: String {
    case onboarding = "OnboardingViewController"
    case legal = "LegalViewController"
    case username = "UsernameViewController"
    case security = "SecurityViewController"
    case languages = "LanguagesViewController"
    case termsAndPrivacy = "TermsAndPrivacyViewController"
    case passcode = "PasscodeViewController"
    case exchange = "ExchangeViewController"
    case receive = "ReceiveViewController"
    case send = "SendViewController"
    case wallets = "WalletsViewController"
    case recoveryPhrase = "RecoveryPhraseViewController"
    case legalSettings = "LegalSettingsViewController"
    case homePage = "HomePageViewController"
    case login = "LoginViewController"
    case logout = "LogoutViewController"
    case camera = "CameraViewController"
    case completeSend = "CompleteSendViewController"
    case sendSuccessfullyVC = "SendSuccessfullyViewController"
    case exchangeAmountVC = "ExchangeAmountViewController"
    case exchangeCompletedVC = "ExchangeCompletedViewController"
    case coinPageVC = "CoinPageViewController"
    case currencyVC = "CurrencyViewController"
    case themeVC = "ThemeViewController"
    case appLock = "AppLockViewController"
    case securitySettingsVC = "SecuritySettingsViewController"
    case eosActivationVC = "EosActivationViewController"
    case faqVC = "FaqViewController"
    case notificationsVC = "NotificationsViewController"
    case referralVC = "ReferralViewController"
    case howItWorksVC = "HowItWorksViewController"
    case payoutVC = "PayoutViewController"
    case detailsVC = "ReferralDetailsViewController"
    case selectCountryVC = "SelectCountryViewController"
    case topUpVC = "TopUpViewController"
    case topupSucceededVC = "TopupSucceededViewController"
    case topupExpiredVC = "TopupExpiredViewController"
}

extension UIStoryboard {
    
    class func get(flow: StoryboardFlow) -> UIStoryboard {
        return UIStoryboard(name: flow.rawValue, bundle: nil)
    }
    
    class func instantiateFlow(_ flow: StoryboardFlow) -> UIViewController {
        let flowSB = UIStoryboard.get(flow: flow)
        let initialVC = flowSB.instantiateInitialViewController()!
        
        return initialVC
    }
    
    func get(controller controllerID: StoryboardControllerID) -> UIViewController {
        return self.instantiateViewController(withIdentifier: controllerID.rawValue)
    }
    
}

