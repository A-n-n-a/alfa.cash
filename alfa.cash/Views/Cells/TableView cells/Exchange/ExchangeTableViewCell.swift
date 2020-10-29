//
//  ExchangeTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 24.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore

class ExchangeTableViewCell: ACTableViewCell {

    @IBOutlet weak var titleLabel: ACLabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyView: UIView!
    
    var type: ExchangeType = .from
    
    var coin: CoinType? {
        didSet {
            selectionStyle = .none
            
            let title = type == .from ? "SEND" : "RECEIVE"
            titleLabel.setText(title)
            
            amountLabel.text = "0.00"
            
            if let coin = coin {
                currencyView.isHidden = false
                currencyLabel.text = coin.currency.uppercased()
            } else {
                currencyView.isHidden = true
            }
        }
    }
    
    var amount: String? {
        didSet {
            amountLabel.text = amount
        }
    }
    
}
