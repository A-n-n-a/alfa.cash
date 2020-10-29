//
//  TopupSucceededViewController.swift
//  alfa.cash
//
//  Created by Anna on 9/2/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class TopupSucceededViewController: UIViewController {
    
    @IBOutlet weak var orderIdLabel: BlueLabelOpacity!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phoneLabel: BlueLabel!
    @IBOutlet weak var amountLabel: BlueLabel!
    @IBOutlet weak var coinAmountLabel: BlueLabelOpacity!
    
    var topupResponse: TopupResponse?
    var phone: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        savePhoneNumber()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupUI() {
        scrollView.contentInsetAdjustmentBehavior = .never
        guard let topup = topupResponse else { return }
        orderIdLabel.text = "\("TOPUP_ORDER_ID".localized()): \(topup.orderId)"
        amountLabel.text = "$\(topup.usdAmount)"
        coinAmountLabel.text = "(\(topup.coinAmount) \(topup.coinCurrency.uppercased()))"
        
        if let phone = phone {
            phoneLabel.text = phone
        }
    }
    
    func savePhoneNumber() {
        if let phone = phone {
            UserDefaults.standard.set(phone, forKey: Constants.Main.udLastPhone)
        }
    }

    @IBAction func backHomeAction(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func topupAnotherMobile(_ sender: Any) {
        if let stack = navigationController?.viewControllers {
            for vc in stack {
                if vc is SelectCountryViewController {
                    navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
    }
    
}
