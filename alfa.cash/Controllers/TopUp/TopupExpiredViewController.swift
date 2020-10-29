//
//  TopupExpiredViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 02.09.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class TopupExpiredViewController: UIViewController {
    
    @IBOutlet weak var orderIdLabel: BlueLabelOpacity!
    
    var orderId: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI() 
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupUI() {
        guard let orderId = orderId else { return }
        orderIdLabel.text = "\("TOPUP_ORDER_ID".localized()): \(orderId)"
    }
    

    @IBAction func toHomePage(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func restartTopup(_ sender: Any) {
        if let stack = navigationController?.viewControllers {
            for vc in stack {
                if vc is SelectCountryViewController {
                    navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
    }
    
}
