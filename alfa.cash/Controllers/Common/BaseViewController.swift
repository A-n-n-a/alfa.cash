//
//  BaseViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 14.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import RxLocalizer
import RxSwift

class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var window: UIWindow? {
        return UIApplication.shared.keyWindow
    }
    let blackView = UIView()
    var rightBarButton: UIBarButtonItem!
    var rightButtonSelector: Selector!
    var subtitleLabel: ACLabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        blackView.alpha = 0
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
    
    func updateBlackView() {
        blackView.backgroundColor = ThemeManager.currentTheme == .day ? UIColor.kDefaultBackgroundNight.withAlphaComponent(0.78) : UIColor.kBlackColor.withAlphaComponent(0.78) 
    }
    
    
    func setUpNavBar(title: String, rightButtonTitle: String? = nil, rightButtonSelector: Selector? = nil) {
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: 60)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
            let view = UIView(frame: navigationController?.navigationBar.frame ?? CGRect.zero)
            view.backgroundColor = ThemeManager.currentTheme.associatedObject.defaultBackgroundColor
            let image = view.asImage()
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.view.backgroundColor = .clear
//        } else {
//            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//            self.navigationController?.navigationBar.shadowImage = UIImage()
//            self.navigationController?.navigationBar.isTranslucent = true
//            self.navigationController?.view.backgroundColor = .clear
//        }
        
        //set title
            
//            if forSettings {
//                let label = NavBarLabelSettings(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
//                label.setText(title)
//                label.textAlignment = .center
//                label.adjustsFontSizeToFitWidth = true
//                navigationItem.titleView = label
//            } else if forLogin {
//                let label = ACLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
//                label.setText(title)
//                label.adjustsFontSizeToFitWidth = true
//                label.textColor = .white
//                label.textAlignment = .center
//                navigationItem.titleView = label
//            } else {
                let label = NavBarLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
                label.setText(title)
                label.textAlignment = .center
                label.adjustsFontSizeToFitWidth = true
                navigationItem.titleView = label
//            }
            
//        }
        
        // set left title button
            var button: UIButton
//            if forSettings {
//                button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
//                button.backgroundColor = forSettings ? UIColor.kWhiteColor : UIColor.kDefaultBackgroundNight
//                button.layer.cornerRadius = 16
//                button.clipsToBounds = true
//                let backButtonImage = forSettings ? #imageLiteral(resourceName: "backArrowBlack") : #imageLiteral(resourceName: "backArrow")
//                button.setImage(backButtonImage, for: .normal)
//            } else {
                button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                let backImage = ThemeManager.currentTheme == .day ?  #imageLiteral(resourceName: "backArrowBlack") : #imageLiteral(resourceName: "backArrow")
                button.setImage(backImage, for: .normal)
//            }
            button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
            let goBackButton = UIBarButtonItem.init(customView: button)
            
            self.navigationItem.leftBarButtonItems = [goBackButton]
//        }
        
        // set right button
        if let title = rightButtonTitle, let selector = rightButtonSelector {
            self.rightButtonSelector = selector
            let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            rightButton.setTitle(title, for: .normal)
            rightButton.setTitleColor(.kButtonColor, for: .normal)
            rightButton.addTarget(self, action: selector, for: .touchUpInside)
            let rightBarButton = UIBarButtonItem.init(customView: rightButton)
            
            self.navigationItem.rightBarButtonItems = [rightBarButton]
        } else {
            self.rightButtonSelector = nil
        }
    }
    
    func setUpWhiteNavBarForLogin(title: String) {
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: 60)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        let view = UIView(frame: navigationController?.navigationBar.frame ?? CGRect.zero)
        view.backgroundColor = .white
        let image = view.asImage()
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = .clear
        
        //set title
            
        let label = ACLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.setText(title)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        navigationItem.titleView = label
        
        setBackButton(black: true)
    }
    
    func setUpBlueNavBar(title: String, hideBackButton: Bool = false) {
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: 60)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        //set title
        
        let label = ACLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.setText(title)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        navigationItem.titleView = label
            
        // set left button
        if !hideBackButton {
            setBackButton(black: false)
        }
    }
    
    func setUpHomeNavBar(title: String, hideBackButton: Bool = false) {
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: 60)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        
        let view = UIView(frame: navigationController?.navigationBar.frame ?? CGRect.zero)
        view.backgroundColor = ThemeManager.currentTheme.associatedObject.homePageBackgroundColor
        let image = view.asImage()
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = .clear
        
        //set title
        
        let label = ACLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.setText(title)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        navigationItem.titleView = label
            
        // set left button
        if !hideBackButton {
            setBackButton(black: false)
        }
    }
    
    func setUpTransactionsNavBar(title: String, subtitle: String? = nil, rightButtonImage: UIImage? = nil, rightButtonSelector: Selector? = nil, theme: Bool = true) {
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: 60)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        var color: UIColor
        var textColor: UIColor
        var headerColor: UIColor
        if theme {
            switch ThemeManager.currentTheme {
            case .day:
                color = .white
                textColor = .kNavBarTextColor
                headerColor = .kHeaderColor
            case .night:
                color = .kDefaultBackgroundNight
                textColor = .white
                headerColor = UIColor.white.withAlphaComponent(0.5)
            default:
                color = .kDefaultBackgroundTrueNight
                textColor = .white
                headerColor = UIColor.white.withAlphaComponent(0.5)
            }
        } else {
            color = .white
            textColor = .kNavBarTextColor
            headerColor = .kHeaderColor
        }
        
        let view = UIView(frame: navigationController?.navigationBar.frame ?? CGRect.zero)
        view.backgroundColor = color
        let image = view.asImage()
        
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = .clear
        
        
        //set title
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        var labels = [UILabel]()
        let titleLabel = ACLabel(frame: CGRect(x: 0, y: 10, width: 200, height: 22))
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = title
        titleLabel.textColor = textColor
        titleLabel.textAlignment = .center
        labels.append(titleLabel)
        if let subtitle = subtitle {
            subtitleLabel = ACLabel(frame: CGRect(x: 0, y: 26, width: 200, height: 18))
            subtitleLabel?.text = subtitle
            subtitleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            subtitleLabel?.textColor = headerColor
            subtitleLabel?.textAlignment = .center
            subtitleLabel?.adjustsFontSizeToFitWidth = true
            if let subtitleLabel = subtitleLabel {
                labels.append(subtitleLabel)
            }
        }
        
        let stack = UIStackView(arrangedSubviews: labels)
        stack.spacing = 3
        stack.frame = CGRect(x: 0, y: 0, width: 200, height: 43)
        stack.axis = .vertical
        
        titleView.addSubview(stack)
        navigationItem.titleView = titleView
        
        // set left button
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        button.setImage(#imageLiteral(resourceName: "backArrowBlack").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = textColor
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let goBackButton = UIBarButtonItem.init(customView: button)
        
        self.navigationItem.leftBarButtonItems = [goBackButton]
        
        // set right button
        if let image = rightButtonImage, let selector = rightButtonSelector {
            self.rightButtonSelector = selector
            let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            rightButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton.tintColor = textColor
            rightButton.addTarget(self, action: selector, for: .touchUpInside)
            let rightBarButton = UIBarButtonItem.init(customView: rightButton)
            
            self.navigationItem.rightBarButtonItems = [rightBarButton]
        } else {
            self.rightButtonSelector = nil
        }
    }
    
    func setBackButton(black: Bool) {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let image = black ? #imageLiteral(resourceName: "backArrowBlack") : #imageLiteral(resourceName: "backArrow")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let goBackButton = UIBarButtonItem.init(customView: button)
        
        self.navigationItem.leftBarButtonItems = [goBackButton]
    }
    
    func setRightIcon(_ image: UIImage) {
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        rightButton.setImage(image, for: .normal)
        rightButton.addTarget(self, action: rightButtonSelector, for: .touchUpInside)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 17, bottom: 10, right: 17)
        rightBarButton = UIBarButtonItem.init(customView: rightButton)
        
        self.navigationItem.rightBarButtonItems = [rightBarButton]
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func cellId(_ cellClass: AnyClass) -> String {
        return String(describing: cellClass)
    }
    
    func showError<T>(_ error: T) {
        var title = ""
        if let err = error as? ACError {
            if err.code == 401 { //toket is dead
                guard let loginVC = UIStoryboard.get(flow: .loginFlow).get(controller: .login) as? LoginViewController else { return }
                self.navigationController?.setViewControllers([loginVC], animated: true)
                return
            }
            title = err.error ?? err.errmsg ?? err.message
        } else if let err = error as? Error {
            title = err.localizedDescription
        } else if let err = error as? Error {
            title = err.localizedDescription
        } else if let err = error as? String {
            title = err
        }
        let myAlert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        let myAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            myAlert.addAction(action)
        }
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func moveToHomePage() {
        if let homePageVC = UIStoryboard.get(flow: .home).instantiateInitialViewController() {
            self.navigationController?.setViewControllers([homePageVC], animated: true)
        }
    }
    
    func updateLayout(_ animated: Bool = true) {
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleDismiss() {
        
    }
    
    func getTransactions(page: Int = 0, type: TransactionType? = nil, currency: String? = nil, completion: (() -> Void)? = nil) {
        NetworkManager.getTransactions(page: page, currency: currency, type: type) { (transactions, error) in
            DispatchQueue.main.async {
                if let transactions = transactions {
                    if page > 0 {
                        TransactionManager.transactions.append(contentsOf: transactions)
                    } else {
                        TransactionManager.transactions = transactions
                    }
                }
                completion?()
            }
        }
    }
    
    @objc func getWallets(completion: ((Bool) -> Void)? = nil) {
        NetworkManager.getWallets { [weak self] (wallets, error) in
            DispatchQueue.main.async {
                if let wallets = wallets {
                    WalletManager.wallets = wallets
                    completion?(true)
                }
                if let error = error {
                    self?.showError(error)
                    completion?(false)
                }
            }
        }
    }
    
//    func getTransactionsWithFilters(type: TransactionType? = nil, currency: String? = nil, completion: (() -> Void)? = nil) {
//        NetworkManager.getTransactions(currency: currency, type: type) { (transactions, error) in
//            DispatchQueue.main.async {
//                if let transactions = transactions {
//                    TransactionManager.transactions = transactions
//                }
//                completion?()
//            }
//        }
//    }
    
    func getProfile(ping: Bool = false, completion: ((Bool) -> Void)? = nil) {
        NetworkManager.getProfile { [weak self] (profile, error) in
            DispatchQueue.main.async {
                if let profile = profile {
                    if ping {
                        if let prevProfile = ApplicationManager.profile, prevProfile.differentFrom(profile) {
                            ApplicationManager.profile = profile
                            self?.showAlert(title: "PROFILE_WAS_CHANGED_TITLE".localized(), message: "PROFILE_WAS_CHANGED_MESSAGE".localized(), actions: [UIAlertAction(title: "OK".localized(), style: .default, handler: { (_) in
                                if let settingsVC = UIStoryboard.get(flow: .settings).instantiateInitialViewController() as? SettingsViewController {
                                    self?.navigationController?.pushViewController(settingsVC, animated: true)
                                }
                            })])
                        }
                    } else {
                        ApplicationManager.profile = profile
                    }
                    completion?(true)
                }
                if let error = error {
                    self?.showError(error)
                    completion?(false)
                }
            }
        }
    }
    
    func clearCookies() {
        guard let cookies = HTTPCookieStorage.shared.cookies else { return }
        for cookie in cookies {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }
    
    func connectToAlfacash() {
        clearCookies()
        if let url = ApplicationManager.referralUrl {
            WebViewManager.shared.openURL(url, from: self, title: "CONNECT_TO_ALFACASH")
        }
    }
}
