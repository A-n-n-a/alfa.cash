//
//  OnboardingCollectionViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 14.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import Lottie

class OnboardingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: ACLabel!
    @IBOutlet weak var subtitleLabel: ACLabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var logo: UIImageView!
    
    var onboardingType: OnboardingType! {
        didSet {
            setupCell()
        }
    }
    
    var lottieView: AnimationView!
   
    func setupCell() {
        switch onboardingType {
        case .logo:
            titleLabel.isHidden = true
            logo.isHidden = false
            subtitleLabel.setText("ALL_YOUR_DIGITAL_ASSETS_IN_YOUR_DEVICE")
        case .digital:
            titleLabel.isHidden = false
            logo.isHidden = true
            titleLabel.setText("ALL_YOUR_DIGITAL_ASSETS_IN_YOUR_DEVICE")
            subtitleLabel.setText("EASY_AND_SECURE_CRYPTO_WALLET")
        case .coins:
            titleLabel.isHidden = false
            logo.isHidden = true
            titleLabel.setText("OVER_COINS_TOKENS")
            subtitleLabel.setText("DECENTRALISED_EXCHANGES_MORE")
        case .send:
            titleLabel.isHidden = false
            logo.isHidden = true
            titleLabel.setText("SEND_AND_RECEIVE_AT_EASE")
            subtitleLabel.setText("SEND_OR_RECEIVE_CRYPTO_DESCRIPTION")
            
        default:
            break
        }
        
        topConstraint.constant = UIDevice.current.iPhoneSE() ? 238 : 298
    }
}

