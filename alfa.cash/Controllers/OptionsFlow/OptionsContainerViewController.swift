//
//  OptionsContainerViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 17.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import BitcoinKit
import Secp256k1Kit
import CommonCrypto
import CryptorECC
import TrustWalletCore
import iCarousel


protocol ContainerViewControllerDelegate {
    func nextButtonAction(skip: Bool)
}

protocol ChildViewControllerDelegate {
    var delegate: ContainerViewControllerDelegate? { get set }
}

class OptionsContainerViewController: BaseViewController {

    @IBOutlet weak var carousel: iCarousel!
    
    var currentChild: ChildType! {
        willSet {
            removeChild()
        }
        didSet {
            showChild()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentChild = .legal
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        setUpCarousel()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUpCarousel() {
        carousel.type = .invertedWheel
        carousel.bounces = false
        carousel.delegate = self
        carousel.dataSource = self
    }
    
    @objc func switchChildVC() {
        switch currentChild {
        case .legal:
            currentChild = .username
        case .username:
            currentChild = .security
        case .security:
            currentChild = .legal
        default:
            break
        }
    }
    
    func showChild() {
        switch currentChild {
        case .legal:
            showChild(LegalViewController.self)
        case .username:
            showChild(UsernameViewController.self)
        case .security:
            showChild(SecurityViewController.self)
            default:
            break
        }
    }

    func showChild(_ childClass: AnyClass) {
        let id = String(describing: childClass)
        guard let screenId = StoryboardControllerID(rawValue: id) else { return }
        if var vc = UIStoryboard.get(flow: .options).get(controller: screenId) as? ChildViewControllerDelegate {
            vc.delegate = self
            
            showChildViewController(vc as! UIViewController)
        }
    }
    
    private func showChildViewController(_ viewController: UIViewController) {
        
        addChild(viewController)
        view.addSubview(viewController.view)

        viewController.view.topAnchor.constraint(equalTo: carousel.bottomAnchor).isActive = true
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            viewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        viewController.didMove(toParent: self)
    }
    
    func removeChild() {
        switch currentChild {
        case .legal:
            removeChild(LegalViewController.self)
        case .username:
            removeChild(UsernameViewController.self)
        case .security:
            removeChild(SecurityViewController.self)
            default:
            break
        }
    }
    
    func removeChild(_ childClass: AnyClass) {
        let id = String(describing: childClass)
        guard let screenId = StoryboardControllerID(rawValue: id) else { return }
        let vc = UIStoryboard.get(flow: .options).get(controller: screenId)
            
            removeChildViewController(vc)
    }

    private func removeChildViewController(_  viewController: UIViewController) {
        
        viewController.willMove(toParent: nil)

        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    func stringToPrivateKey(_ str: String) -> SecKey? {
        var error: Unmanaged<CFError>?
        
        guard let data = stringToNSData(str) else {
            #if DEBUG
            print("String not in Base64 format: \(str)")
            #endif
            return nil
        }
        
        let privKeyAttr: [String: Any] =
        [kSecAttrKeyType as String:            kSecAttrKeyTypeEC,
         kSecAttrKeySizeInBits as String:      4096,
         kSecAttrKeyClass as String:           kSecAttrKeyClassPrivate]
        
        guard let key = SecKeyCreateWithData(data, privKeyAttr as CFDictionary, &error) else {
            print(error!.takeRetainedValue() as Error)
            return nil
        }
        return key
    }
    
    private func stringToNSData(_ str: String) -> NSData? {
        return NSData(base64Encoded: str,
                      options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
    }
    
    
    private func retrieveMnemonica() {
            
        do {
            if let authData =  try WalletManager.getRegisterAuthData() {
                register(authData: authData)
            }
        } catch {
            showError(error)
        }
    }
    
    func register(authData: AuthData) {
        guard let securityVC = navigationController?.viewControllers.last?.children.last as? SecurityViewController else { return }
        securityVC.startLoadingAnimation()
        NetworkManager.register(authData: authData) { [weak self] (registration, error) in
            DispatchQueue.main.async {
                securityVC.stopLoadingAnimation()
                if let error = error {
                    self?.showError(error)
                }
                if let registration = registration {
                    let token = registration.auth.token
                    #if DEBUG
                    print("TOKEN: ", token)
                    #endif
                    KeychainWrapper.standart.set(value: token, forKey: Constants.Main.udToken)
                    ApplicationManager.profile = registration.user
                    ApplicationManager.tempUsername = nil
                    self?.sendWallets()
                    self?.updateLanguage()
                }
            }
        }
    }
    
    func sendWallets() {
        guard let walletsData = WalletManager.generatedAddresses() else {
            let error = ACError(message: "AN_UNEXPECTED_ERROR".localized())
            showError(error)
            return
        }
        
        NetworkManager.generateWallets(walletsData: walletsData) { [weak self] (wallets, error) in
            DispatchQueue.main.async {
                self?.moveToHomePage()
                if let error = error {
                    self?.showError(error)
                }
            }
        }
    }
    
    func updateLanguage() {
        if var profileCopy = ApplicationManager.profile, let language = ApplicationManager.tempLanguage  {
            profileCopy.language = language
            NetworkManager.updateProfile(profileCopy) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if success {
                        self?.getProfile(completion: { (_) in
                            DispatchQueue.main.async {
                                LanguageManager.switchLanguage()
                            }
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func internalBackAction(_ sender: Any) {
        switch currentChild {
        case .legal:
            navigationController?.popViewController(animated: true)
        case .username:
            carousel.scrollToItem(at: 0, duration: 0.7)
            currentChild = .legal
        case .security:
            carousel.scrollToItem(at: 1, duration: 0.7)
            currentChild = .username
        default:
            break
        }
    }
}

extension OptionsContainerViewController: ContainerViewControllerDelegate {
    func nextButtonAction(skip: Bool) {
        switch currentChild {
        case .legal:
            carousel.scrollToItem(at: 1, duration: 0.7)
            currentChild = .username
        case .username:
            carousel.scrollToItem(at: 2, duration: 0.7)
            currentChild = .security
        case .security:
            retrieveMnemonica()
            break
        default:
            break
        }
    }
}

extension OptionsContainerViewController: iCarouselDelegate, iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 3
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let screen = UIScreen.main.bounds
        let container = UIView(frame: CGRect(x: 0, y: 0, width: screen.width * 0.6, height: screen.height * 0.4))
        let imageView = UIImageView(frame: container.frame)
        imageView.image = UIImage(named: "Animation\(index)")
        imageView.contentMode = .scaleAspectFit
        container.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        if index != 1 {
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        }
        
        return container
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .visibleItems: return 1
        case .wrap: return 0
        case .fadeMinAlpha: return 1
        default: return value
        }
    }
}

enum ChildType: String {
    case legal = "LegalViewController"
    case username = "UsernameViewController"
    case security = "SecurityViewController"
}
