//
//  Presenter.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 30.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class Presenter {
    
    static func showCustomScreen() {
        let mnemonicExists = KeychainWrapper.standart.getMnemonic() != nil
        let passcodeExists = KeychainWrapper.standart.value(forKey: Constants.Main.udPasscode) != nil
//        let loginSecurityDisabled = UserDefaults.standard.bool(forKey: Constants.Main.udLoginSecurityDisabled)
        
        var biometryEnabled: Bool {
            return UserDefaults.standard.bool(forKey: Constants.Main.udBiometryEnabled)
        }
        if mnemonicExists, passcodeExists {
//            if loginSecurityDisabled {
//                showHomePage()
//            } else {
                showPin()
//            }
        } else {
            showOnboarding()
        }
    }
    
    static func showOnboarding() {
        if let vc = UIStoryboard.get(flow: .onboarding).get(controller: .onboarding) as? OnboardingViewController {
            LanguageManager.switchLanguage(language: .english)
            let navVC = UINavigationController(rootViewController: vc)
            Presenter.setRootVC(navVC)
        }
    }
    
    private static func showPin() {
        #if targetEnvironment(simulator)
        if let homePageVC = UIStoryboard.get(flow: .home).instantiateInitialViewController() {
            let navVC = UINavigationController(rootViewController: homePageVC)
            
            Presenter.setRootVC(navVC)
        }
        #else
          if let vc = UIStoryboard.get(flow: .options).get(controller: .passcode) as? PasscodeViewController {
              vc.mode = .login
              let navVC = UINavigationController(rootViewController: vc)
              
              Presenter.setRootVC(navVC)
          }
        #endif
    }
    
    private static func showHomePage() {
        
        if let vc = UIStoryboard.get(flow: .home).instantiateInitialViewController() {
            let navVC = UINavigationController(rootViewController: vc)
            Presenter.setRootVC(navVC)
        }
    }
    
    private static func setRootVC(_ vc: UIViewController) {
        if #available(iOS 13.0, *) {
            let sharedSceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            let window = sharedSceneDelegate?.window
            window?.rootViewController = vc
        } else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.window?.rootViewController = vc
            }
        }
    }
}
