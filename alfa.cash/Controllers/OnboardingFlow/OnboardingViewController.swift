//
//  OnboardingViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 14.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import Lottie

class OnboardingViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var signUpButton: BlueButton!
    @IBOutlet weak var loginButton: NoBorderButton!
    @IBOutlet weak var logoIcon: UIImageView!
    @IBOutlet weak var logoTop: NSLayoutConstraint!
    @IBOutlet weak var lottieContainer: UIView!
    
    var lottieDigitView: AnimationView?
    var lottieCoinView: AnimationView?
    var lottieSendView: AnimationView?
    var onboardingType: OnboardingType? = .logo {
        didSet {
            if oldValue != onboardingType {
                switchLottieAnimathion()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setUpUI() {
        collectionView.register(cellClass: OnboardingCollectionViewCell.self)
        showUpUI()
        
        lottieDigitView = initLottieWithAnimation(name: "round", loopMode: .loop)
        lottieDigitView?.isHidden = true
        lottieCoinView = initLottieWithAnimation(name: "horizontal", loopMode: .loop)
        lottieCoinView?.isHidden = true
        lottieSendView = initLottieWithAnimation(name: "vertical", loopMode: .playOnce)
        lottieSendView?.isHidden = true
    }
    
    func switchLottieAnimathion() {
        
        switch onboardingType {
        case .digital:
            lottieDigitView?.isHidden = false
            lottieDigitView?.play()
            
            lottieCoinView?.stop()
            lottieCoinView?.isHidden = true
            lottieSendView?.stop()
            lottieSendView?.isHidden = true
        case .send:
            lottieSendView?.isHidden = false
            lottieSendView?.play()
            
            lottieCoinView?.stop()
            lottieCoinView?.isHidden = true
            lottieDigitView?.stop()
            lottieDigitView?.isHidden = true
        case .coins:
            lottieCoinView?.isHidden = false
            lottieCoinView?.play()
            
            lottieSendView?.stop()
            lottieSendView?.isHidden = true
            lottieDigitView?.stop()
            lottieDigitView?.isHidden = true
        default:
            lottieCoinView?.stop()
            lottieCoinView?.isHidden = true
            lottieSendView?.stop()
            lottieSendView?.isHidden = true
            lottieDigitView?.stop()
            lottieDigitView?.isHidden = true
            break
        }
    }
    
    func initLottieWithAnimation(name: String, loopMode: LottieLoopMode) -> AnimationView {
        let lottieView = AnimationView(name: name)
        lottieView.contentMode = .scaleAspectFit
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.loopMode = loopMode
       
        self.lottieContainer.addSubview(lottieView)
        
        lottieView.topAnchor.constraint(equalTo: lottieContainer.topAnchor).isActive = true
        lottieView.leadingAnchor.constraint(equalTo: lottieContainer.leadingAnchor).isActive = true
        lottieView.trailingAnchor.constraint(equalTo: lottieContainer.trailingAnchor).isActive = true
        lottieView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        let offset: CGFloat = UIDevice.current.isFrameless() ? -200 : -100
        lottieView.bottomAnchor.constraint(equalTo: lottieContainer.bottomAnchor, constant:  offset).isActive = true
//        lottieView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return lottieView
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showUpUI() {
        
        UIView.animate(withDuration: 0.4, animations: {
            if UIDevice.current.iPhoneSE() {
                self.logoIcon.transform = CGAffineTransform(translationX: 0, y: -60)
            } else {
                self.collectionView.alpha = 1
                self.pageControl.alpha = 1
                self.signUpButton.alpha = 1
                self.loginButton.alpha = 1
            }
        }) { (_) in
            if UIDevice.current.iPhoneSE() {
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.alpha = 1
                    self.pageControl.alpha = 1
                    self.signUpButton.alpha = 1
                    self.loginButton.alpha = 1
                }
            }
        }
    }
    
    @IBAction func signup(_ sender: Any) {
        if let setLanguageVC = UIStoryboard.get(flow: .setLanguage).instantiateInitialViewController() as? SetLanguageViewController {
            navigationController?.pushViewController(setLanguageVC, animated: true)
        }
    }
    
    @IBAction func login(_ sender: Any) {
        if let loginVC = UIStoryboard.get(flow: .loginFlow).get(controller: .login) as? LoginViewController {
            navigationController?.pushViewController(loginVC, animated: true)
        }
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OnboardingCollectionViewCell.self), for:indexPath) as! OnboardingCollectionViewCell
        let onboardingType = OnboardingType(rawValue: indexPath.item)
        cell.onboardingType = onboardingType
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.contentOffset.x/UIScreen.main.bounds.width
        pageControl.currentPage = Int(pageWidth)
        onboardingType = OnboardingType(rawValue: pageControl.currentPage)
        logoIcon.alpha = max(0, 1 - pageWidth)
    }
}


enum OnboardingType: Int {
    case logo = 0
    case digital
    case coins
    case send
}
